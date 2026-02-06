package com.nozie.paymentservice.application.service;

import com.nozie.common.dto.ApiResponse;
import com.nozie.common.event.SubscriptionActivatedEvent;
import com.nozie.paymentservice.api.dto.SubscriptionRequest;
import com.nozie.paymentservice.api.dto.SubscriptionResponse;
import com.nozie.paymentservice.domain.model.Subscription;
import com.nozie.paymentservice.domain.model.SubscriptionPlan;
import com.nozie.paymentservice.domain.model.Transaction;
import com.nozie.paymentservice.domain.repository.SubscriptionPlanRepository;
import com.nozie.paymentservice.domain.repository.SubscriptionRepository;
import com.nozie.paymentservice.domain.repository.TransactionRepository;
import com.nozie.paymentservice.infrastructure.client.CustomerClient;
import com.nozie.paymentservice.infrastructure.client.dto.CustomerDTO;
import com.nozie.paymentservice.infrastructure.messaging.PaymentEventProducer;
import com.nozie.paymentservice.infrastructure.stripe.StripeService;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.exception.StripeException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

/**
 * Subscription Application Service - Xử lý logic đăng ký gói Premium
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class SubscriptionApplicationService {

    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository planRepository;
    private final CustomerClient customerClient;
    private final StripeService stripeService;
    private final PaymentEventProducer eventProducer;
    private final TransactionRepository transactionRepository;

    /**
     * Lấy danh sách các gói cước đang hoạt động
     */
    public List<SubscriptionPlan> getActivePlans() {
        return planRepository.findByActiveTrue();
    }

    /**
     * Lấy thông tin gói cước theo type
     */
    public SubscriptionPlan getPlanByType(String planType) {
        return planRepository.findByPlanType(planType.toUpperCase())
                .orElseThrow(() -> new RuntimeException("Plan not found: " + planType));
    }

    /**
     * Tạo Checkout Session để người dùng thanh toán
     */
    @Transactional
    public SubscriptionResponse createSubscriptionSession(SubscriptionRequest request) {
        log.info("Creating subscription session for user {} with plan {}",
                request.getUserId(), request.getPlanType());

        // 1. Validate User exists in Customer Service
        CustomerDTO customer = validateUser(request.getUserId());

        // 2. Check if user already has an active subscription
        Optional<Subscription> activeSubscription = getActiveSubscription(request.getUserId());
        if (activeSubscription.isPresent()) {
            Subscription activeSub = activeSubscription.get();
            String activePlanType = activeSub.getPlan().getPlanType();

            // If same plan, reject
            if (activePlanType.equalsIgnoreCase(request.getPlanType())) {
                throw new RuntimeException("Bạn đã đang sử dụng gói " + activeSub.getPlan().getName() +
                        ". Vui lòng hủy gói hiện tại trước khi đăng ký lại.");
            }

            // If different plan (upgrade/downgrade), also reject - must cancel first
            throw new RuntimeException("Bạn đang có gói " + activeSub.getPlan().getName() +
                    " còn hiệu lực đến " + activeSub.getEndDate() +
                    ". Vui lòng hủy gói hiện tại trước khi chuyển sang gói khác.");
        }

        // 3. Check for pending subscriptions (not yet paid)
        Optional<Subscription> pendingSubscription = subscriptionRepository
                .findFirstByUserIdAndStatusOrderByCreatedAtDesc(request.getUserId(), Subscription.Status.PENDING);
        if (pendingSubscription.isPresent()) {
            log.info("User {} has a pending subscription, returning existing checkout session", request.getUserId());
            // Return existing checkout session URL if still valid (within 24 hours)
            Subscription pending = pendingSubscription.get();
            if (pending.getCreatedAt() != null &&
                    pending.getCreatedAt().plusHours(24).isAfter(LocalDateTime.now())) {
                // TODO: Could return existing session URL here, but session might be expired
                // For now, we'll create a new one and mark old as expired
            }
            // Mark old pending as expired
            pending.setStatus(Subscription.Status.EXPIRED);
            subscriptionRepository.save(pending);
        }

        // 4. Get Plan
        SubscriptionPlan plan = getPlanByType(request.getPlanType());

        try {
            // 5. Create or get Stripe Customer
            String stripeCustomerId = stripeService.createOrGetCustomer(customer.getEmail());

            // 6. Create Checkout Session
            Session session = stripeService.createCheckoutSession(
                    stripeCustomerId,
                    plan,
                    request.getSuccessUrl(),
                    request.getCancelUrl());

            // 7. Create Pending Subscription record
            Subscription subscription = Subscription.builder()
                    .userId(request.getUserId())
                    .plan(plan)
                    .status(Subscription.Status.PENDING)
                    .stripeCheckoutSessionId(session.getId())
                    .stripeCustomerId(stripeCustomerId)
                    .build();
            subscription = subscriptionRepository.save(subscription);

            // 8. Return response with checkout URL
            return SubscriptionResponse.builder()
                    .subscriptionId(subscription.getId())
                    .checkoutUrl(session.getUrl())
                    .sessionId(session.getId())
                    .status(subscription.getStatus().name())
                    .planName(plan.getName())
                    .price(plan.getPrice())
                    .build();

        } catch (StripeException e) {
            log.error("Stripe error creating checkout session: {}", e.getMessage());
            throw new RuntimeException("Failed to create checkout session: " + e.getMessage());
        }
    }

    /**
     * Hủy subscription của user
     */
    @Transactional
    public Subscription cancelSubscription(Long userId) {
        log.info("Canceling subscription for user {}", userId);

        Optional<Subscription> activeSubscription = getActiveSubscription(userId);
        if (activeSubscription.isEmpty()) {
            throw new RuntimeException("Không tìm thấy gói đăng ký đang hoạt động");
        }

        Subscription subscription = activeSubscription.get();

        try {
            // Cancel on Stripe first
            if (subscription.getStripeSubscriptionId() != null) {
                stripeService.cancelSubscription(subscription.getStripeSubscriptionId());
            }

            // Update local record
            subscription.cancel();
            subscription = subscriptionRepository.save(subscription);

            // TODO: Send event to customer-service to update subscription status to FREE
            log.info("Subscription {} canceled for user {}", subscription.getId(), userId);

            return subscription;
        } catch (StripeException e) {
            log.error("Error canceling subscription on Stripe: {}", e.getMessage());
            throw new RuntimeException("Không thể hủy gói đăng ký: " + e.getMessage());
        }
    }

    /**
     * Xử lý Stripe Webhook events
     */
    @Transactional
    public void handleStripeWebhook(String payload, String sigHeader) {
        try {
            Event event = stripeService.parseWebhookEvent(payload, sigHeader);
            String eventType = event.getType();
            log.info("Processing Stripe webhook event: {}", eventType);

            switch (eventType) {
                case "checkout.session.completed":
                    handleCheckoutSessionCompleted(event);
                    break;
                case "customer.subscription.deleted":
                    handleSubscriptionDeleted(event);
                    break;
                case "invoice.payment_failed":
                    handlePaymentFailed(event);
                    break;
                default:
                    log.info("Unhandled event type: {}", eventType);
            }
        } catch (SignatureVerificationException e) {
            log.error("Invalid webhook signature: {}", e.getMessage());
            throw new RuntimeException("Invalid webhook signature");
        }
    }

    /**
     * Xử lý khi checkout hoàn thành
     */
    private void handleCheckoutSessionCompleted(Event event) {
        Session session;
        try {
            // Try standard deserialization first
            if (event.getDataObjectDeserializer().getObject().isPresent()) {
                session = (Session) event.getDataObjectDeserializer().getObject().get();
            } else {
                // Use unsafe deserialize for API version mismatch
                session = (Session) event.getDataObjectDeserializer().deserializeUnsafe();
            }
        } catch (Exception e) {
            log.error("Failed to deserialize checkout session: {}", e.getMessage());
            // For test/simulated events, just log and return OK
            log.warn("This may be a test event - ignoring");
            return;
        }

        String sessionId = session.getId();
        String stripeSubscriptionId = session.getSubscription();

        log.info("Processing checkout session: {} with subscription: {}", sessionId, stripeSubscriptionId);

        Optional<Subscription> optSub = subscriptionRepository.findByStripeCheckoutSessionId(sessionId);
        if (optSub.isEmpty()) {
            log.warn("Subscription not found for session: {} - this may be a test/simulated event", sessionId);
            return;
        }

        Subscription subscription = optSub.get();

        try {
            // Get subscription details from Stripe
            com.stripe.model.Subscription stripeSub = stripeService.getSubscription(stripeSubscriptionId);

            LocalDateTime startDate = LocalDateTime.ofInstant(
                    Instant.ofEpochSecond(stripeSub.getCurrentPeriodStart()),
                    ZoneId.systemDefault());
            LocalDateTime endDate = LocalDateTime.ofInstant(
                    Instant.ofEpochSecond(stripeSub.getCurrentPeriodEnd()),
                    ZoneId.systemDefault());

            // Activate subscription
            subscription.activate(stripeSubscriptionId, startDate, endDate);
            subscriptionRepository.save(subscription);

            // Create Transaction record
            Transaction transaction = Transaction.builder()
                    .userId(subscription.getUserId())
                    .subscription(subscription)
                    .stripeTransactionId(session.getPaymentIntent())
                    .amount(session.getAmountTotal() != null ? session.getAmountTotal() / 100.0 : 0.0) // Stripe amount
                                                                                                       // is in cents
                    .currency(session.getCurrency())
                    .status("PAID")
                    .paymentMethod("STRIPE")
                    .createdAt(LocalDateTime.now())
                    .build();
            transactionRepository.save(transaction);
            log.info("Transaction record saved for user {}", subscription.getUserId());

            // Send event to notify Customer Service
            SubscriptionActivatedEvent activatedEvent = new SubscriptionActivatedEvent(
                    subscription.getId(),
                    subscription.getUserId(),
                    subscription.getPlan().getPlanType(),
                    subscription.getPlan().getName(),
                    startDate,
                    endDate,
                    stripeSubscriptionId,
                    subscription.getStripeCustomerId());
            eventProducer.sendSubscriptionActivatedEvent(activatedEvent);

            log.info("Subscription {} activated for user {}",
                    subscription.getId(), subscription.getUserId());

        } catch (StripeException e) {
            log.error("Error retrieving Stripe subscription: {}", e.getMessage());
            throw new RuntimeException("Failed to retrieve subscription details");
        }
    }

    /**
     * Xử lý khi subscription bị hủy trên Stripe
     */
    private void handleSubscriptionDeleted(Event event) {
        com.stripe.model.Subscription stripeSub = (com.stripe.model.Subscription) event.getDataObjectDeserializer()
                .getObject()
                .orElseThrow(() -> new RuntimeException("Failed to deserialize subscription"));

        Optional<Subscription> optSub = subscriptionRepository.findByStripeSubscriptionId(stripeSub.getId());
        if (optSub.isPresent()) {
            Subscription subscription = optSub.get();
            subscription.cancel();
            subscriptionRepository.save(subscription);
            log.info("Subscription {} canceled", subscription.getId());
        }
    }

    /**
     * Xử lý khi thanh toán thất bại
     */
    private void handlePaymentFailed(Event event) {
        log.warn("Payment failed event received: {}", event.getId());
        // TODO: Notify customer about failed payment
    }

    /**
     * Lấy subscription đang active của user
     */
    public Optional<Subscription> getActiveSubscription(Long userId) {
        return subscriptionRepository.findFirstByUserIdAndStatusOrderByEndDateDesc(
                userId, Subscription.Status.ACTIVE);
    }

    /**
     * Kiểm tra user có subscription active không
     */
    public boolean hasActiveSubscription(Long userId) {
        Optional<Subscription> activeSub = getActiveSubscription(userId);
        return activeSub.isPresent() && activeSub.get().isActive();
    }

    /**
     * Lấy lịch sử subscription của user
     */
    public List<Subscription> getSubscriptionHistory(Long userId) {
        return subscriptionRepository.findByUserId(userId);
    }

    private CustomerDTO validateUser(Long userId) {
        try {
            ApiResponse<CustomerDTO> response = customerClient.getCustomerByUserId(userId);
            if (response == null || response.getData() == null) {
                throw new RuntimeException("Customer profile not found for user ID: " + userId);
            }
            return response.getData();
        } catch (Exception e) {
            log.error("Error validating user: {}", e.getMessage());
            throw new RuntimeException("Failed to validate user: " + e.getMessage());
        }
    }
}
