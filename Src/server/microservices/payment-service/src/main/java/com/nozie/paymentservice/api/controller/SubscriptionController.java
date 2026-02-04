package com.nozie.paymentservice.api.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.paymentservice.api.dto.SubscriptionRequest;
import com.nozie.paymentservice.api.dto.SubscriptionResponse;
import com.nozie.paymentservice.application.service.SubscriptionApplicationService;
import com.nozie.paymentservice.domain.model.Subscription;
import com.nozie.paymentservice.domain.model.SubscriptionPlan;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Subscription Controller - API cho đăng ký gói Premium
 */
@RestController
@RequestMapping("/api/subscriptions")
@CrossOrigin(origins = "*")
public class SubscriptionController {

    private static final Logger log = LoggerFactory.getLogger(SubscriptionController.class);

    private final SubscriptionApplicationService subscriptionService;

    public SubscriptionController(SubscriptionApplicationService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    /**
     * GET /api/subscriptions/plans - Lấy danh sách các gói cước
     */
    @GetMapping("/plans")
    public ResponseEntity<ApiResponse<List<SubscriptionPlan>>> getPlans() {
        log.info("GET /api/subscriptions/plans - Fetching active plans");
        List<SubscriptionPlan> plans = subscriptionService.getActivePlans();
        return ResponseEntity.ok(ApiResponse.success(plans));
    }

    /**
     * POST /api/subscriptions/subscribe - Tạo Checkout Session
     */
    @PostMapping("/subscribe")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> createSubscription(
            @Valid @RequestBody SubscriptionRequest request) {
        log.info("POST /api/subscriptions/subscribe - Creating subscription for customer: {}, plan: {}",
                request.getCustomerId(), request.getPlanType());
        SubscriptionResponse response = subscriptionService.createSubscriptionSession(request);
        return new ResponseEntity<>(ApiResponse.success("Checkout session created", response), HttpStatus.CREATED);
    }

    /**
     * GET /api/subscriptions/active/{customerId} - Kiểm tra subscription active
     */
    @GetMapping("/active/{customerId}")
    public ResponseEntity<ApiResponse<Boolean>> checkActiveSubscription(@PathVariable Long customerId) {
        log.info("GET /api/subscriptions/active/{} - Checking active subscription", customerId);
        boolean hasActive = subscriptionService.hasActiveSubscription(customerId);
        return ResponseEntity.ok(ApiResponse.success(hasActive));
    }

    /**
     * GET /api/subscriptions/current/{customerId} - Lấy thông tin subscription hiện
     * tại
     */
    @GetMapping("/current/{customerId}")
    public ResponseEntity<ApiResponse<Subscription>> getCurrentSubscription(@PathVariable Long customerId) {
        log.info("GET /api/subscriptions/current/{} - Fetching current subscription", customerId);
        return subscriptionService.getActiveSubscription(customerId)
                .map(sub -> ResponseEntity.ok(ApiResponse.success(sub)))
                .orElse(ResponseEntity.ok(ApiResponse.success("No active subscription", null)));
    }

    /**
     * GET /api/subscriptions/history/{customerId} - Lịch sử subscription
     */
    @GetMapping("/history/{customerId}")
    public ResponseEntity<ApiResponse<List<Subscription>>> getSubscriptionHistory(@PathVariable Long customerId) {
        log.info("GET /api/subscriptions/history/{} - Fetching subscription history", customerId);
        List<Subscription> history = subscriptionService.getSubscriptionHistory(customerId);
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    /**
     * Stripe Webhook endpoint - Xử lý events từ Stripe
     */
    @PostMapping("/webhook")
    public ResponseEntity<String> handleWebhook(
            @RequestBody String payload,
            @RequestHeader(value = "Stripe-Signature", required = false) String sigHeader) {
        log.info("POST /api/subscriptions/webhook - Received webhook");
        try {
            if (sigHeader == null || sigHeader.isEmpty()) {
                log.warn("Missing Stripe-Signature header");
                return ResponseEntity.badRequest().body("Missing signature");
            }
            subscriptionService.handleStripeWebhook(payload, sigHeader);
            return ResponseEntity.ok("Webhook processed");
        } catch (Exception e) {
            log.error("Error processing webhook: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Webhook error: " + e.getMessage());
        }
    }
}
