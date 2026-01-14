package com.nozie.customerservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.common.exception.ResourceNotFoundException;
import com.nozie.customerservice.dto.CustomerRequest;
import com.nozie.customerservice.model.Customer;
import com.nozie.customerservice.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Layer 2: Business Logic Layer - Customer Service
 */
@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;

    public Customer createCustomer(CustomerRequest request) {
        log.info("Creating customer: {}", request.getEmail());

        if (customerRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Customer with email '" + request.getEmail() + "' already exists");
        }

        Customer customer = new Customer();
        customer.setFirebaseUid(request.getFirebaseUid());
        customer.setEmail(request.getEmail());
        customer.setFullName(request.getFullName());
        customer.setPhoneNumber(request.getPhoneNumber());
        customer.setAvatarUrl(request.getAvatarUrl());
        customer.setDateOfBirth(request.getDateOfBirth());
        customer.setGender(request.getGender());

        return customerRepository.save(customer);
    }

    @Transactional(readOnly = true)
    public List<Customer> getAllCustomers() {
        return customerRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Customer getCustomerById(Long id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", id));
    }

    @Transactional(readOnly = true)
    public Customer getCustomerByEmail(String email) {
        return customerRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "email", email));
    }

    @Transactional(readOnly = true)
    public Customer getCustomerByFirebaseUid(String firebaseUid) {
        return customerRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "firebaseUid", firebaseUid));
    }

    public Customer updateCustomer(Long id, CustomerRequest request) {
        Customer existingCustomer = getCustomerById(id);

        if (!existingCustomer.getEmail().equals(request.getEmail()) &&
                customerRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Customer with email '" + request.getEmail() + "' already exists");
        }

        existingCustomer.setEmail(request.getEmail());
        existingCustomer.setFullName(request.getFullName());
        existingCustomer.setPhoneNumber(request.getPhoneNumber());
        existingCustomer.setAvatarUrl(request.getAvatarUrl());
        existingCustomer.setDateOfBirth(request.getDateOfBirth());
        existingCustomer.setGender(request.getGender());

        return customerRepository.save(existingCustomer);
    }

    public void deleteCustomer(Long id) {
        if (!customerRepository.existsById(id)) {
            throw new ResourceNotFoundException("Customer", "id", id);
        }
        customerRepository.deleteById(id);
    }

    public Customer updateStripeCustomerId(Long id, String stripeCustomerId) {
        Customer customer = getCustomerById(id);
        customer.setStripeCustomerId(stripeCustomerId);
        return customerRepository.save(customer);
    }

    public Customer updateSubscription(Long id, boolean isSubscribed) {
        Customer customer = getCustomerById(id);
        customer.setIsSubscribed(isSubscribed);
        return customerRepository.save(customer);
    }
}
