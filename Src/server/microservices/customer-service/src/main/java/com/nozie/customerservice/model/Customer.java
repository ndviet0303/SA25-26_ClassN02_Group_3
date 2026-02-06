package com.nozie.customerservice.model;

import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Customer Entity
 */
@Entity
@Table(name = "customers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Customer {

    public enum SubscriptionStatus {
        FREE, PREMIUM, VIP
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", unique = true, nullable = false)
    private Long userId;

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "date_of_birth")
    private String dateOfBirth;

    private String gender;

    @Column(name = "avatar_url")
    private String avatarUrl;

    private String country;

    private String bio;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "is_subscribed")
    @Builder.Default
    private Boolean isSubscribed = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "subscription_status")
    @Builder.Default
    private SubscriptionStatus subscriptionStatus = SubscriptionStatus.FREE;

    @Column(name = "subscription_end_date")
    private LocalDateTime subscriptionEndDate;

    @Column(name = "stripe_customer_id")
    private String stripeCustomerId;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Domain logic
    public void activateSubscription(SubscriptionStatus status, LocalDateTime endDate, String stripeCustomerId) {
        this.isSubscribed = true;
        this.subscriptionStatus = status;
        this.subscriptionEndDate = endDate;
        this.stripeCustomerId = stripeCustomerId;
    }

    public void deactivateSubscription() {
        this.isSubscribed = false;
        this.subscriptionStatus = SubscriptionStatus.FREE;
        this.subscriptionEndDate = null;
    }

    public boolean hasActiveSubscription() {
        return isSubscribed &&
                subscriptionEndDate != null &&
                LocalDateTime.now().isBefore(subscriptionEndDate);
    }
}
