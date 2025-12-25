package com.nozie.common.event;

import java.math.BigDecimal;
import java.io.Serializable;

/**
 * Event published when a payment is successful.
 */
public class PaymentSucceededEvent implements Serializable {
    private Long transactionId;
    private Long customerId;
    private Long movieId;
    private BigDecimal amount;
    private String currency;

    public PaymentSucceededEvent() {
    }

    public PaymentSucceededEvent(Long transactionId, Long customerId, Long movieId, BigDecimal amount,
            String currency) {
        this.transactionId = transactionId;
        this.customerId = customerId;
        this.movieId = movieId;
        this.amount = amount;
        this.currency = currency;
    }

    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }

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

    @Override
    public String toString() {
        return "PaymentSucceededEvent{" +
                "transactionId=" + transactionId +
                ", customerId=" + customerId +
                ", movieId=" + movieId +
                ", amount=" + amount +
                ", currency='" + currency + '\'' +
                '}';
    }
}
