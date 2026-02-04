package com.nozie.paymentservice.api.dto;

import lombok.*;
import java.time.LocalDateTime;

/**
 * Subscription Response DTO - Trả về thông tin đăng ký
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubscriptionResponse {

    private Long subscriptionId;
    private String checkoutUrl; // URL Stripe Checkout để redirect người dùng
    private String sessionId; // Stripe Checkout Session ID
    private String status;
    private String planName;
    private Double price;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
}
