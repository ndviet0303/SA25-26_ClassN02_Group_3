package com.nozie.paymentservice.domain.repository;

import com.nozie.paymentservice.domain.model.SubscriptionPlan;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * SubscriptionPlan Repository
 */
@Repository
public interface SubscriptionPlanRepository extends JpaRepository<SubscriptionPlan, Long> {

    Optional<SubscriptionPlan> findByPlanType(String planType);

    List<SubscriptionPlan> findByActiveTrue();

    Optional<SubscriptionPlan> findByStripePriceId(String stripePriceId);
}
