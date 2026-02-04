package com.nozie.common.event;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Event published when a subscription is activated after successful payment.
 * Customer Service will listen to this event and update customer's subscription
 * status.
 */
public class SubscriptionActivatedEvent implements Serializable {

    private Long subscriptionId;
    private Long userId;
    private String planType; // PREMIUM_MONTHLY, PREMIUM_YEARLY, VIP_MONTHLY, VIP_YEARLY
    private String planName;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String stripeSubscriptionId;
    private String stripeCustomerId;

    public SubscriptionActivatedEvent() {
    }

    public SubscriptionActivatedEvent(Long subscriptionId, Long userId, String planType,
            String planName, LocalDateTime startDate, LocalDateTime endDate,
            String stripeSubscriptionId, String stripeCustomerId) {
        this.subscriptionId = subscriptionId;
        this.userId = userId;
        this.planType = planType;
        this.planName = planName;
        this.startDate = startDate;
        this.endDate = endDate;
        this.stripeSubscriptionId = stripeSubscriptionId;
        this.stripeCustomerId = stripeCustomerId;
    }

    // Getters and Setters
    public Long getSubscriptionId() {
        return subscriptionId;
    }

    public void setSubscriptionId(Long subscriptionId) {
        this.subscriptionId = subscriptionId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getPlanType() {
        return planType;
    }

    public void setPlanType(String planType) {
        this.planType = planType;
    }

    public String getPlanName() {
        return planName;
    }

    public void setPlanName(String planName) {
        this.planName = planName;
    }

    public LocalDateTime getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }

    public LocalDateTime getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }

    public String getStripeSubscriptionId() {
        return stripeSubscriptionId;
    }

    public void setStripeSubscriptionId(String stripeSubscriptionId) {
        this.stripeSubscriptionId = stripeSubscriptionId;
    }

    public String getStripeCustomerId() {
        return stripeCustomerId;
    }

    public void setStripeCustomerId(String stripeCustomerId) {
        this.stripeCustomerId = stripeCustomerId;
    }

    @Override
    public String toString() {
        return "SubscriptionActivatedEvent{" +
                "subscriptionId=" + subscriptionId +
                ", userId=" + userId +
                ", planType='" + planType + '\'' +
                ", planName='" + planName + '\'' +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", stripeSubscriptionId='" + stripeSubscriptionId + '\'' +
                ", stripeCustomerId='" + stripeCustomerId + '\'' +
                '}';
    }
}
