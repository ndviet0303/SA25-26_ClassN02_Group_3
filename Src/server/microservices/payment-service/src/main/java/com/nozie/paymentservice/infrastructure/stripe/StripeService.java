package com.nozie.paymentservice.infrastructure.stripe;

import com.nozie.paymentservice.domain.model.SubscriptionPlan;
import com.stripe.Stripe;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.exception.StripeException;
import com.stripe.model.*;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import com.stripe.param.CustomerCreateParams;
import com.stripe.param.CustomerListParams;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * StripeService - Xử lý tích hợp Stripe SDK
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class StripeService {

    @Value("${stripe.secret-key}")
    private String secretKey;

    @Value("${stripe.webhook-secret}")
    private String webhookSecret;

    @Value("${stripe.success-url:http://localhost:3000/payment/success}")
    private String defaultSuccessUrl;

    @Value("${stripe.cancel-url:http://localhost:3000/payment/cancel}")
    private String defaultCancelUrl;

    @PostConstruct
    public void init() {
        Stripe.apiKey = secretKey;
        log.info("Stripe SDK initialized");
    }

    /**
     * Tạo hoặc lấy Stripe Customer dựa trên email
     */
    public String createOrGetCustomer(String email) throws StripeException {
        // Tìm customer đã tồn tại bằng CustomerListParams (compatible với nhiều SDK
        // versions)
        CustomerListParams listParams = CustomerListParams.builder()
                .setEmail(email)
                .setLimit(1L)
                .build();
        CustomerCollection customers = Customer.list(listParams);

        if (!customers.getData().isEmpty()) {
            String existingCustomerId = customers.getData().get(0).getId();
            log.info("Found existing Stripe customer: {}", existingCustomerId);
            return existingCustomerId;
        }

        // Tạo customer mới
        CustomerCreateParams params = CustomerCreateParams.builder()
                .setEmail(email)
                .build();
        Customer customer = Customer.create(params);
        log.info("Created new Stripe customer: {}", customer.getId());
        return customer.getId();
    }

    /**
     * Tạo Checkout Session cho subscription
     */
    public Session createCheckoutSession(String stripeCustomerId, SubscriptionPlan plan,
            String successUrl, String cancelUrl) throws StripeException {
        String effectiveSuccessUrl = successUrl != null ? successUrl : defaultSuccessUrl;
        String effectiveCancelUrl = cancelUrl != null ? cancelUrl : defaultCancelUrl;

        SessionCreateParams params = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.SUBSCRIPTION)
                .setCustomer(stripeCustomerId)
                .setSuccessUrl(effectiveSuccessUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(effectiveCancelUrl)
                .addLineItem(
                        SessionCreateParams.LineItem.builder()
                                .setPrice(plan.getStripePriceId())
                                .setQuantity(1L)
                                .build())
                .putMetadata("plan_id", plan.getId().toString())
                .putMetadata("plan_type", plan.getPlanType())
                .build();

        Session session = Session.create(params);
        log.info("Created Stripe Checkout Session: {}", session.getId());
        return session;
    }

    /**
     * Parse và validate Webhook Event từ Stripe
     */
    public Event parseWebhookEvent(String payload, String sigHeader) throws SignatureVerificationException {
        Event event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
        log.info("Parsed Stripe webhook event: {}", event.getType());
        return event;
    }

    /**
     * Lấy thông tin Subscription từ Stripe
     */
    public com.stripe.model.Subscription getSubscription(String subscriptionId) throws StripeException {
        return com.stripe.model.Subscription.retrieve(subscriptionId);
    }

    /**
     * Hủy Subscription trên Stripe
     */
    public com.stripe.model.Subscription cancelSubscription(String subscriptionId) throws StripeException {
        com.stripe.model.Subscription subscription = com.stripe.model.Subscription.retrieve(subscriptionId);
        return subscription.cancel();
    }
}
