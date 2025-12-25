package com.nozie.paymentservice.domain.repository;

import com.nozie.paymentservice.domain.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Transaction Repository - Domain Layer
 */
@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    List<Transaction> findByCustomerId(Long customerId);

    boolean existsByCustomerIdAndMovieIdAndStatus(Long customerId, Long movieId, String status);

    Transaction findByStripePaymentIntentId(String paymentIntentId);
}
