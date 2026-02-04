package com.nozie.paymentservice.domain.repository;

import com.nozie.paymentservice.domain.model.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Subscription Repository
 */
@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {

    List<Subscription> findByUserId(Long userId);

    Optional<Subscription> findByUserIdAndStatus(Long userId, Subscription.Status status);

    Optional<Subscription> findByStripeCheckoutSessionId(String sessionId);

    Optional<Subscription> findByStripeSubscriptionId(String subscriptionId);

    // Tìm subscription đang active của user
    Optional<Subscription> findFirstByUserIdAndStatusOrderByEndDateDesc(Long userId,
            Subscription.Status status);
}
