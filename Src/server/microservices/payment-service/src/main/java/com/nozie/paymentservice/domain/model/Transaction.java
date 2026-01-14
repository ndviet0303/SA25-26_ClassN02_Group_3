package com.nozie.paymentservice.domain.model;

import lombok.*;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Transaction Entity - Domain Model
 */
@Entity
@Table(name = "transactions")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "movie_id", nullable = false)
    private String movieId;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal amount;

    @Builder.Default
    private String currency = "usd";

    @Builder.Default
    private String status = "pending"; // pending, succeeded, failed, canceled

    @Column(name = "stripe_payment_intent_id")
    private String stripePaymentIntentId;

    @Column(name = "stripe_customer_id")
    private String stripeCustomerId;

    @Column(name = "charge_id")
    private String chargeId;

    @Column(name = "error_message")
    private String errorMessage;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "failed_at")
    private LocalDateTime failedAt;

    @Column(name = "canceled_at")
    private LocalDateTime canceledAt;

    // Static factory method for creation
    public static Transaction create(Long customerId, String movieId, BigDecimal amount, String currency) {
        return Transaction.builder()
                .customerId(customerId)
                .movieId(movieId)
                .amount(amount)
                .currency(currency)
                .status("pending")
                .createdAt(LocalDateTime.now())
                .build();
    }

    // Domain logic - Intent revealing methods
    public void markAsSucceeded(String stripePaymentIntentId, String stripeCustomerId, String chargeId) {
        if ("succeeded".equals(this.status)) {
            return; // Already succeeded
        }
        this.status = "succeeded";
        this.stripePaymentIntentId = stripePaymentIntentId;
        this.stripeCustomerId = stripeCustomerId;
        this.chargeId = chargeId;
        this.paidAt = LocalDateTime.now();
    }

    public void markAsFailed(String errorMessage) {
        this.status = "failed";
        this.errorMessage = errorMessage;
        this.failedAt = LocalDateTime.now();
    }

    public void cancel() {
        if ("pending".equals(this.status)) {
            this.status = "canceled";
            this.canceledAt = LocalDateTime.now();
        }
    }
}
