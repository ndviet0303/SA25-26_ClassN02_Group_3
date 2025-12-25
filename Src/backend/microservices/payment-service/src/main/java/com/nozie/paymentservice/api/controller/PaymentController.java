package com.nozie.paymentservice.api.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.paymentservice.api.dto.PaymentRequest;
import com.nozie.paymentservice.api.dto.PaymentResponse;
import com.nozie.paymentservice.application.service.PaymentApplicationService;
import com.nozie.paymentservice.domain.model.Transaction;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Payment Controller - Presentation Layer
 */
@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

    private final PaymentApplicationService paymentService;

    public PaymentController(PaymentApplicationService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<PaymentResponse>> createPayment(@Valid @RequestBody PaymentRequest request) {
        log.info("POST /api/payments/create - Creating payment for customer: {}", request.getCustomerId());
        PaymentResponse response = paymentService.createPayment(request);
        return new ResponseEntity<>(ApiResponse.success("Payment created", response), HttpStatus.CREATED);
    }

    @GetMapping("/transactions/{customerId}")
    public ResponseEntity<ApiResponse<List<Transaction>>> getTransactionsByCustomer(@PathVariable Long customerId) {
        log.info("GET /api/payments/transactions/{} - Fetching transactions", customerId);
        List<Transaction> transactions = paymentService.getTransactionsByCustomer(customerId);
        return ResponseEntity.ok(ApiResponse.success(transactions));
    }

    @GetMapping("/transaction/{id}")
    public ResponseEntity<ApiResponse<Transaction>> getTransactionById(@PathVariable Long id) {
        log.info("GET /api/payments/transaction/{} - Fetching transaction", id);
        Transaction transaction = paymentService.getTransactionById(id);
        return ResponseEntity.ok(ApiResponse.success(transaction));
    }

    @GetMapping("/check-purchase")
    public ResponseEntity<ApiResponse<Boolean>> checkPurchase(
            @RequestParam Long customerId,
            @RequestParam Long movieId) {
        log.info("GET /api/payments/check-purchase - Checking purchase for customer: {}, movie: {}", customerId,
                movieId);
        boolean hasPurchased = paymentService.hasPurchased(customerId, movieId);
        return ResponseEntity.ok(ApiResponse.success(hasPurchased));
    }

    @PostMapping("/webhook")
    public ResponseEntity<String> handleWebhook(@RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {
        log.info("POST /api/payments/webhook - Received webhook");
        // TODO: Implement Stripe webhook handling in application service
        return ResponseEntity.ok("Webhook received");
    }
}
