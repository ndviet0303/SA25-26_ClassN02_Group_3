package com.nozie.paymentservice.dto;

/**
 * Payment Response DTO
 */
public class PaymentResponse {

    private Long transactionId;
    private String clientSecret;
    private String ephemeralKey;
    private String customerId;

    public PaymentResponse() {
    }

    public PaymentResponse(Long transactionId, String clientSecret, String ephemeralKey, String customerId) {
        this.transactionId = transactionId;
        this.clientSecret = clientSecret;
        this.ephemeralKey = ephemeralKey;
        this.customerId = customerId;
    }

    // Getters and Setters
    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }

    public String getEphemeralKey() {
        return ephemeralKey;
    }

    public void setEphemeralKey(String ephemeralKey) {
        this.ephemeralKey = ephemeralKey;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }
}
