package com.nozie.paymentservice.domain.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;
import jakarta.persistence.*;

/**
 * SubscriptionPlan Entity - Định nghĩa các gói cước Premium
 */
@Entity
@Table(name = "subscription_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class SubscriptionPlan {

    public enum PlanType {
        FREE, PREMIUM_MONTHLY, PREMIUM_QUARTERLY, PREMIUM_YEARLY, VIP_MONTHLY, VIP_YEARLY, STUDENT_MONTHLY
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String planType;

    @Column(nullable = false)
    private String name;

    private String description;

    @Column(nullable = false)
    private Double price;

    @Builder.Default
    private String currency = "vnd";

    // Số tháng hiệu lực: 1 = Monthly, 12 = Yearly
    @Column(name = "interval_months", nullable = false)
    @Builder.Default
    private Integer intervalMonths = 1;

    // ID của Price trong Stripe Dashboard
    @Column(name = "stripe_price_id")
    private String stripePriceId;

    @Builder.Default
    private Boolean active = true;
}
