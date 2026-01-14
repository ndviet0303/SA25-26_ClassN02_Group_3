package com.nozie.paymentservice.api.dto;

import lombok.*;

/**
 * Payment Response DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentResponse {

    private Long transactionId;
    private String clientSecret;
    private String ephemeralKey;
    private String customerId;
}
