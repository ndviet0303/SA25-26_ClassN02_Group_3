package com.nozie.customerservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.customerservice.dto.CustomerInterestRequest;
import com.nozie.customerservice.dto.CustomerRequest;
import com.nozie.customerservice.model.*;
import com.nozie.customerservice.service.CustomerService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Consolidated Customer Controller - handles both account and profile info
 */
@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = "*")
public class CustomerController {

    private static final Logger log = LoggerFactory.getLogger(CustomerController.class);
    private final CustomerService customerService;

    public CustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Customer>> createCustomer(@Valid @RequestBody CustomerRequest request) {
        log.info("POST /api/customers - Creating customer for user ID: {}", request.getUserId());
        Customer customer = customerService.createCustomer(request);
        return new ResponseEntity<>(ApiResponse.success("Customer created successfully", customer), HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Customer>>> getAllCustomers() {
        log.info("GET /api/customers - Fetching all customers");
        List<Customer> customers = customerService.getAllCustomers();
        return ResponseEntity.ok(ApiResponse.success(customers));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Customer>> getCustomerById(@PathVariable Long id) {
        log.info("GET /api/customers/{} - Fetching customer info", id);
        Customer customer = customerService.getCustomerById(id);
        return ResponseEntity.ok(ApiResponse.success(customer));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Customer>> getCustomerByUserId(@PathVariable Long userId) {
        log.info("GET /api/customers/user/{} - Fetching customer by user ID", userId);
        Customer customer = customerService.getCustomerByUserId(userId);
        return ResponseEntity.ok(ApiResponse.success(customer));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Customer>> updateCustomer(@PathVariable Long id,
            @Valid @RequestBody CustomerRequest request) {
        log.info("PUT /api/customers/{} - Updating customer/profile info", id);
        Customer customer = customerService.updateCustomer(id, request);
        return ResponseEntity.ok(ApiResponse.success("Customer updated successfully", customer));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCustomer(@PathVariable Long id) {
        log.info("DELETE /api/customers/{} - Deleting customer", id);
        customerService.deleteCustomer(id);
        return ResponseEntity.ok(ApiResponse.success("Customer deleted successfully", null));
    }

    @PatchMapping("/{id}/subscription")
    public ResponseEntity<ApiResponse<Customer>> updateSubscription(
            @PathVariable Long id,
            @RequestParam boolean isSubscribed) {
        log.info("PATCH /api/customers/{}/subscription - Updating subscription", id);
        Customer customer = customerService.updateSubscription(id, isSubscribed);
        return ResponseEntity.ok(ApiResponse.success("Subscription updated successfully", customer));
    }

    // ==================== Interest Endpoints ====================

    @GetMapping("/{id}/interests")
    public ResponseEntity<ApiResponse<List<CustomerInterest>>> getInterests(@PathVariable Long id) {
        log.info("GET /api/customers/{}/interests", id);
        List<CustomerInterest> interests = customerService.getInterests(id);
        return ResponseEntity.ok(ApiResponse.success(interests));
    }

    @PutMapping("/{id}/interests")
    public ResponseEntity<ApiResponse<List<CustomerInterest>>> setInterests(
            @PathVariable Long id,
            @RequestBody CustomerInterestRequest request) {
        log.info("PUT /api/customers/{}/interests - Setting {} interests", id, request.getGenreSlugs().size());
        List<CustomerInterest> interests = customerService.setInterests(id, request);
        return ResponseEntity.ok(ApiResponse.success("Interests updated successfully", interests));
    }

    @PostMapping("/{id}/interests/{genreSlug}")
    public ResponseEntity<ApiResponse<CustomerInterest>> addInterest(
            @PathVariable Long id,
            @PathVariable String genreSlug) {
        log.info("POST /api/customers/{}/interests/{}", id, genreSlug);
        CustomerInterest interest = customerService.addInterest(id, genreSlug);
        return new ResponseEntity<>(ApiResponse.success("Interest added", interest), HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}/interests/{genreSlug}")
    public ResponseEntity<ApiResponse<Void>> removeInterest(
            @PathVariable Long id,
            @PathVariable String genreSlug) {
        log.info("DELETE /api/customers/{}/interests/{}", id, genreSlug);
        customerService.removeInterest(id, genreSlug);
        return ResponseEntity.ok(ApiResponse.success("Interest removed", null));
    }

    // ==================== UC12: Watchlist ====================

    @GetMapping("/{id}/watchlist")
    public ResponseEntity<ApiResponse<List<WatchlistItem>>> getWatchlist(@PathVariable Long id) {
        log.info("GET /api/customers/{}/watchlist", id);
        List<WatchlistItem> items = customerService.getWatchlist(id);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    @PostMapping("/{id}/watchlist")
    public ResponseEntity<ApiResponse<WatchlistItem>> addToWatchlist(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        String movieId = body.get("movieId");
        if (movieId == null || movieId.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("movieId is required"));
        }
        log.info("POST /api/customers/{}/watchlist - movieId={}", id, movieId);
        WatchlistItem item = customerService.addToWatchlist(id, movieId);
        return new ResponseEntity<>(ApiResponse.success("Added to watchlist", item), HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}/watchlist/{movieId}")
    public ResponseEntity<ApiResponse<Void>> removeFromWatchlist(
            @PathVariable Long id,
            @PathVariable String movieId) {
        log.info("DELETE /api/customers/{}/watchlist/{}", id, movieId);
        customerService.removeFromWatchlist(id, movieId);
        return ResponseEntity.ok(ApiResponse.success("Removed from watchlist", null));
    }

    // ==================== UC19: Viewing History ====================

    @GetMapping("/{id}/history")
    public ResponseEntity<ApiResponse<List<ViewingHistory>>> getViewingHistory(
            @PathVariable Long id,
            @RequestParam(defaultValue = "50") int limit) {
        log.info("GET /api/customers/{}/history - limit={}", id, limit);
        List<ViewingHistory> history = customerService.getViewingHistory(id, limit);
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    @PostMapping("/{id}/history")
    public ResponseEntity<ApiResponse<ViewingHistory>> recordViewing(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        String movieId = body.get("movieId") != null ? body.get("movieId").toString() : null;
        if (movieId == null || movieId.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("movieId is required"));
        }
        Integer progress = body.get("progressSeconds") != null ? ((Number) body.get("progressSeconds")).intValue()
                : null;
        log.info("POST /api/customers/{}/history - movieId={}", id, movieId);
        ViewingHistory h = customerService.recordViewing(id, movieId, progress);
        return new ResponseEntity<>(ApiResponse.success("Viewing recorded", h), HttpStatus.CREATED);
    }
}
