package com.nozie.paymentservice.domain.repository;

import com.nozie.paymentservice.domain.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByUserId(Long userId);

    List<Transaction> findByStripeTransactionId(String stripeTransactionId);
}
