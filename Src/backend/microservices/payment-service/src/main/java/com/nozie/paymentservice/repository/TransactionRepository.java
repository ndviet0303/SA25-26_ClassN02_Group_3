package com.nozie.paymentservice.repository;

import com.nozie.paymentservice.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Layer 3: Persistence Layer - Transaction Repository
 */
@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByCustomerId(Long customerId);

    List<Transaction> findByMovieId(Long movieId);

    Optional<Transaction> findByStripePaymentIntentId(String stripePaymentIntentId);

    List<Transaction> findByCustomerIdAndStatus(Long customerId, String status);

    boolean existsByCustomerIdAndMovieIdAndStatus(Long customerId, Long movieId, String status);
}

