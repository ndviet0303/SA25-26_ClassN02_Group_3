package com.nozie.paymentservice.domain.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Transaction Entity - Domain Model
 */
@Entity
@Table(name = "transactions")
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

    private String currency = "usd";

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
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "failed_at")
    private LocalDateTime failedAt;

    @Column(name = "canceled_at")
    private LocalDateTime canceledAt;

    // Protected constructor for Hibernate
    protected Transaction() {
    }

    private Transaction(Long customerId, String movieId, BigDecimal amount, String currency) {
        this.customerId = customerId;
        this.movieId = movieId;
        this.amount = amount;
        this.currency = currency;
        this.status = "pending";
        this.createdAt = LocalDateTime.now();
    }

    // Static factory method for creation
    public static Transaction create(Long customerId, String movieId, BigDecimal amount, String currency) {
        return new Transaction(customerId, movieId, amount, currency);
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

    // Getters and Setters (Setters kept for JPA but ideally would be minimized)
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public String getMovieId() {
        return movieId;
    }

    public void setMovieId(String movieId) {
        this.movieId = movieId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStripePaymentIntentId() {
        return stripePaymentIntentId;
    }

    public void setStripePaymentIntentId(String stripePaymentIntentId) {
        this.stripePaymentIntentId = stripePaymentIntentId;
    }

    public String getStripeCustomerId() {
        return stripeCustomerId;
    }

    public void setStripeCustomerId(String stripeCustomerId) {
        this.stripeCustomerId = stripeCustomerId;
    }

    public String getChargeId() {
        return chargeId;
    }

    public void setChargeId(String chargeId) {
        this.chargeId = chargeId;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(LocalDateTime paidAt) {
        this.paidAt = paidAt;
    }

    public LocalDateTime getFailedAt() {
        return failedAt;
    }

    public void setFailedAt(LocalDateTime failedAt) {
        this.failedAt = failedAt;
    }

    public LocalDateTime getCanceledAt() {
        return canceledAt;
    }

    public void setCanceledAt(LocalDateTime canceledAt) {
        this.canceledAt = canceledAt;
    }
}
