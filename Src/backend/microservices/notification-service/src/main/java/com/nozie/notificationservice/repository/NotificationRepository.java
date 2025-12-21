package com.nozie.notificationservice.repository;

import com.nozie.notificationservice.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Layer 3: Persistence Layer - Notification Repository
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    List<Notification> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    List<Notification> findByCustomerIdAndReadFalse(Long customerId);

    long countByCustomerIdAndReadFalse(Long customerId);
}

