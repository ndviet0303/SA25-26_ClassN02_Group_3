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
        log.info("POST /api/subscriptions/subscribe - Creating subscription for user: {}, plan: {}",
                request.getUserId(), request.getPlanType());
        SubscriptionResponse response = subscriptionService.createSubscriptionSession(request);
        return new ResponseEntity<>(ApiResponse.success("Checkout session created", response), HttpStatus.CREATED);
    }

    /**
     * GET /api/subscriptions/active/{userId} - Kiểm tra subscription active
     */
    @GetMapping("/active/{userId}")
    public ResponseEntity<ApiResponse<Boolean>> checkActiveSubscription(@PathVariable Long userId) {
        log.info("GET /api/subscriptions/active/{} - Checking active subscription", userId);
        boolean hasActive = subscriptionService.hasActiveSubscription(userId);
        return ResponseEntity.ok(ApiResponse.success(hasActive));
    }

    /**
     * GET /api/subscriptions/current/{userId} - Lấy thông tin subscription hiện
     * tại
     */
    @GetMapping("/current/{userId}")
    public ResponseEntity<ApiResponse<Subscription>> getCurrentSubscription(@PathVariable Long userId) {
        log.info("GET /api/subscriptions/current/{} - Fetching current subscription", userId);
        return subscriptionService.getActiveSubscription(userId)
                .map(sub -> ResponseEntity.ok(ApiResponse.success(sub)))
                .orElse(ResponseEntity.ok(ApiResponse.success("No active subscription", null)));
    }

    /**
     * GET /api/subscriptions/history/{userId} - Lịch sử subscription
     */
    @GetMapping("/history/{userId}")
    public ResponseEntity<ApiResponse<List<Subscription>>> getSubscriptionHistory(@PathVariable Long userId) {
        log.info("GET /api/subscriptions/history/{} - Fetching subscription history", userId);
        List<Subscription> history = subscriptionService.getSubscriptionHistory(userId);
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
