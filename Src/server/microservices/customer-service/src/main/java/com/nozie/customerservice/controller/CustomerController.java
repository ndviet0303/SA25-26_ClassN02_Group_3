package com.nozie.customerservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.customerservice.dto.CustomerRequest;
import com.nozie.customerservice.model.Customer;
import com.nozie.customerservice.service.CustomerService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 1: Presentation Layer - Customer Controller
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
        log.info("POST /api/customers - Creating customer: {}", request.getEmail());
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
        log.info("GET /api/customers/{} - Fetching customer by ID", id);
        Customer customer = customerService.getCustomerById(id);
        return ResponseEntity.ok(ApiResponse.success(customer));
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<ApiResponse<Customer>> getCustomerByEmail(@PathVariable String email) {
        log.info("GET /api/customers/email/{} - Fetching customer by email", email);
        Customer customer = customerService.getCustomerByEmail(email);
        return ResponseEntity.ok(ApiResponse.success(customer));
    }

    @GetMapping("/firebase/{firebaseUid}")
    public ResponseEntity<ApiResponse<Customer>> getCustomerByFirebaseUid(@PathVariable String firebaseUid) {
        log.info("GET /api/customers/firebase/{} - Fetching customer by Firebase UID", firebaseUid);
        Customer customer = customerService.getCustomerByFirebaseUid(firebaseUid);
        return ResponseEntity.ok(ApiResponse.success(customer));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Customer>> updateCustomer(@PathVariable Long id, @Valid @RequestBody CustomerRequest request) {
        log.info("PUT /api/customers/{} - Updating customer", id);
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
}
