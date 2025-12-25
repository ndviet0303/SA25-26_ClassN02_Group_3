package com.nozie.paymentservice.application.service;

import com.nozie.paymentservice.api.dto.PaymentRequest;
import com.nozie.paymentservice.api.dto.PaymentResponse;
import com.nozie.paymentservice.domain.model.Transaction;
import com.nozie.paymentservice.domain.repository.TransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Payment Application Service - Coordinates domain logic and infrastructure.
 */
@Service
public class PaymentApplicationService {

    private final TransactionRepository transactionRepository;

    public PaymentApplicationService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    @Transactional
    public PaymentResponse createPayment(PaymentRequest request) {
        // Domain logic: Create a transition instance
        Transaction transaction = Transaction.create(
                request.getCustomerId(),
                request.getMovieId(),
                request.getAmount(),
                request.getCurrency());

        // Infrastructure: Save to database
        transaction = transactionRepository.save(transaction);

        // TODO: Infrastructure: Integrate with Stripe
        // Mock Stripe response for now
        PaymentResponse response = new PaymentResponse();
        response.setTransactionId(transaction.getId());
        response.setClientSecret("pi_xxx_secret_xxx");
        response.setEphemeralKey("ek_xxx");
        response.setCustomerId("cus_xxx");

        return response;
    }

    public List<Transaction> getTransactionsByCustomer(Long customerId) {
        return transactionRepository.findByCustomerId(customerId);
    }

    public Transaction getTransactionById(Long id) {
        return transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
    }

    public boolean hasPurchased(Long customerId, Long movieId) {
        return transactionRepository.existsByCustomerIdAndMovieIdAndStatus(customerId, movieId, "succeeded");
    }
}
