package com.nozie.paymentservice.domain.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Subscription Entity - Theo dõi lịch sử đăng ký gói Premium của người dùng
 */
@Entity
@Table(name = "subscriptions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class Subscription {

    public enum Status {
        PENDING, // Đang chờ thanh toán
        ACTIVE, // Đang hoạt động
        CANCELED, // Đã hủy
        EXPIRED // Đã hết hạn
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private SubscriptionPlan plan;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Status status = Status.PENDING;

    // Stripe IDs
    @Column(name = "stripe_subscription_id")
    private String stripeSubscriptionId;

    @Column(name = "stripe_checkout_session_id")
    private String stripeCheckoutSessionId;

    @Column(name = "stripe_customer_id")
    private String stripeCustomerId;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "end_date")
    private LocalDateTime endDate;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "canceled_at")
    private LocalDateTime canceledAt;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Domain logic
    public void activate(String stripeSubscriptionId, LocalDateTime startDate, LocalDateTime endDate) {
        this.status = Status.ACTIVE;
        this.stripeSubscriptionId = stripeSubscriptionId;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public void cancel() {
        this.status = Status.CANCELED;
        this.canceledAt = LocalDateTime.now();
    }

    public void expire() {
        this.status = Status.EXPIRED;
    }

    public boolean isActive() {
        return this.status == Status.ACTIVE &&
                this.endDate != null &&
                LocalDateTime.now().isBefore(this.endDate);
    }
}
