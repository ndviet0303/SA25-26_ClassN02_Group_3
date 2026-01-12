package com.nozie.paymentservice.application.service;

import com.nozie.common.dto.ApiResponse;
import com.nozie.common.event.PaymentSucceededEvent;
import com.nozie.paymentservice.api.dto.PaymentRequest;
import com.nozie.paymentservice.api.dto.PaymentResponse;
import com.nozie.paymentservice.domain.model.Transaction;
import com.nozie.paymentservice.domain.repository.TransactionRepository;
import com.nozie.paymentservice.infrastructure.client.CustomerClient;
import com.nozie.paymentservice.infrastructure.client.MovieClient;
import com.nozie.paymentservice.infrastructure.client.dto.CustomerDTO;
import com.nozie.paymentservice.infrastructure.client.dto.MovieDTO;
import com.nozie.paymentservice.infrastructure.messaging.PaymentEventProducer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Payment Application Service - Coordinates domain logic and infrastructure.
 */
@Service
public class PaymentApplicationService {

    private static final Logger log = LoggerFactory.getLogger(PaymentApplicationService.class);

    private final TransactionRepository transactionRepository;
    private final MovieClient movieClient;
    private final CustomerClient customerClient;
    private final PaymentEventProducer eventProducer;

    public PaymentApplicationService(
            TransactionRepository transactionRepository,
            MovieClient movieClient,
            CustomerClient customerClient,
            PaymentEventProducer eventProducer) {
        this.transactionRepository = transactionRepository;
        this.movieClient = movieClient;
        this.customerClient = customerClient;
        this.eventProducer = eventProducer;
    }

    @Transactional
    public PaymentResponse createPayment(PaymentRequest request) {
        log.info("Creating payment for customer {} and movie {}", request.getCustomerId(), request.getMovieId());

        // 1. Validate Movie exists via Feign Client
        try {
            ApiResponse<MovieDTO> movieResponse = movieClient.getMovieById(request.getMovieId());
            if (movieResponse == null || movieResponse.getData() == null) {
                throw new RuntimeException("Movie not found with ID: " + request.getMovieId());
            }
        } catch (Exception e) {
            log.error("Error validating movie: {}", e.getMessage());
            throw new RuntimeException("Could not validate movie: " + e.getMessage());
        }

        // 2. Validate Customer exists via Feign Client
        try {
            ApiResponse<CustomerDTO> customerResponse = customerClient.getCustomerById(request.getCustomerId());
            if (customerResponse == null || customerResponse.getData() == null) {
                throw new RuntimeException("Customer not found with ID: " + request.getCustomerId());
            }
        } catch (Exception e) {
            log.error("Error validating customer: {}", e.getMessage());
            throw new RuntimeException("Could not validate customer: " + e.getMessage());
        }

        // 3. Domain logic: Create a transition instance
        Transaction transaction = Transaction.create(
                request.getCustomerId(),
                request.getMovieId(),
                request.getAmount(),
                request.getCurrency());

        // 4. Infrastructure: Save to database
        transaction = transactionRepository.save(transaction);

        // 5. Mock Stripe response for now
        PaymentResponse response = new PaymentResponse();
        response.setTransactionId(transaction.getId());
        response.setClientSecret("pi_xxx_secret_xxx");
        response.setEphemeralKey("ek_xxx");
        response.setCustomerId("cus_xxx");

        // 6. Send Async Notification via RabbitMQ
        eventProducer.sendPaymentSucceededEvent(new PaymentSucceededEvent(
                transaction.getId(),
                transaction.getCustomerId(),
                transaction.getMovieId(),
                transaction.getAmount(),
                transaction.getCurrency()));

        return response;
    }

    public List<Transaction> getTransactionsByCustomer(Long customerId) {
        return transactionRepository.findByCustomerId(customerId);
    }

    public Transaction getTransactionById(Long id) {
        return transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
    }

    public boolean hasPurchased(Long customerId, String movieId) {
        return transactionRepository.existsByCustomerIdAndMovieIdAndStatus(customerId, movieId, "succeeded");
    }
}
