package com.nozie.customerservice.repository;

import com.nozie.customerservice.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Layer 3: Persistence Layer - Customer Repository
 */
@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Optional<Customer> findByEmail(String email);

    Optional<Customer> findByFirebaseUid(String firebaseUid);

    Optional<Customer> findByStripeCustomerId(String stripeCustomerId);

    boolean existsByEmail(String email);

    boolean existsByFirebaseUid(String firebaseUid);
}

