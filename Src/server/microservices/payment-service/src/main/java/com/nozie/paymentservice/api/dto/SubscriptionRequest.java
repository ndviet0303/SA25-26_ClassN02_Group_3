package com.nozie.paymentservice.api.dto;

import lombok.*;
import jakarta.validation.constraints.NotNull;

/**
 * Subscription Request DTO - Yêu cầu đăng ký gói Premium
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubscriptionRequest {

    @NotNull(message = "User ID is required")
    private Long userId;

    @NotNull(message = "Plan type is required")
    private String planType; // PREMIUM_MONTHLY, PREMIUM_YEARLY, VIP_MONTHLY, VIP_YEARLY

    private String successUrl; // URL redirect sau khi thanh toán thành công
    private String cancelUrl; // URL redirect nếu người dùng hủy
}
