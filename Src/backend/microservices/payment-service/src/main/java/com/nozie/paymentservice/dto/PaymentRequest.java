package com.nozie.paymentservice.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

/**
 * Payment Request DTO
 */
public class PaymentRequest {

    @NotNull(message = "Customer ID is required")
    private Long customerId;

    @NotNull(message = "Movie ID is required")
    private Long movieId;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;

    private String currency = "usd";

    public PaymentRequest() {
    }

    // Getters and Setters
    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Long getMovieId() {
        return movieId;
    }

    public void setMovieId(Long movieId) {
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
}
