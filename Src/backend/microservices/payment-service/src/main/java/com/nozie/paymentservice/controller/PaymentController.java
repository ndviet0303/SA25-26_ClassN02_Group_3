package com.nozie.paymentservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.paymentservice.dto.PaymentRequest;
import com.nozie.paymentservice.dto.PaymentResponse;
import com.nozie.paymentservice.model.Transaction;
import com.nozie.paymentservice.repository.TransactionRepository;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 1: Presentation Layer - Payment Controller
 */
@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

    private final TransactionRepository transactionRepository;

    public PaymentController(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<PaymentResponse>> createPayment(@Valid @RequestBody PaymentRequest request) {
        log.info("POST /api/payments/create - Creating payment for customer: {}", request.getCustomerId());
        
        // Create transaction record
        Transaction transaction = new Transaction();
        transaction.setCustomerId(request.getCustomerId());
        transaction.setMovieId(request.getMovieId());
        transaction.setAmount(request.getAmount());
        transaction.setCurrency(request.getCurrency());
        transaction.setStatus("pending");
        
        transaction = transactionRepository.save(transaction);
        
        // TODO: Integrate with Stripe to create PaymentIntent
        PaymentResponse response = new PaymentResponse();
        response.setTransactionId(transaction.getId());
        response.setClientSecret("pi_xxx_secret_xxx"); // Replace with actual Stripe client secret
        response.setEphemeralKey("ek_xxx"); // Replace with actual Stripe ephemeral key
        response.setCustomerId("cus_xxx"); // Replace with actual Stripe customer ID
        
        return new ResponseEntity<>(ApiResponse.success("Payment created", response), HttpStatus.CREATED);
    }

    @GetMapping("/transactions/{customerId}")
    public ResponseEntity<ApiResponse<List<Transaction>>> getTransactionsByCustomer(@PathVariable Long customerId) {
        log.info("GET /api/payments/transactions/{} - Fetching transactions", customerId);
        List<Transaction> transactions = transactionRepository.findByCustomerId(customerId);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }

    @GetMapping("/transaction/{id}")
    public ResponseEntity<ApiResponse<Transaction>> getTransactionById(@PathVariable Long id) {
        log.info("GET /api/payments/transaction/{} - Fetching transaction", id);
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        return ResponseEntity.ok(ApiResponse.success(transaction));
    }

    @GetMapping("/check-purchase")
    public ResponseEntity<ApiResponse<Boolean>> checkPurchase(
            @RequestParam Long customerId,
            @RequestParam Long movieId) {
        log.info("GET /api/payments/check-purchase - Checking purchase for customer: {}, movie: {}", customerId, movieId);
        boolean hasPurchased = transactionRepository.existsByCustomerIdAndMovieIdAndStatus(customerId, movieId, "succeeded");
        return ResponseEntity.ok(ApiResponse.success(hasPurchased));
    }

    @PostMapping("/webhook")
    public ResponseEntity<String> handleWebhook(@RequestBody String payload, @RequestHeader("Stripe-Signature") String sigHeader) {
        log.info("POST /api/payments/webhook - Received webhook");
        // TODO: Implement Stripe webhook handling
        return ResponseEntity.ok("Webhook received");
    }
}
