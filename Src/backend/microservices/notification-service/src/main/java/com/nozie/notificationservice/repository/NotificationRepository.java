package com.nozie.notificationservice.repository;

import com.nozie.notificationservice.model.Notification;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Layer 3: Persistence Layer - Notification Repository
 */
@Repository
public interface NotificationRepository extends MongoRepository<Notification, String> {

    List<Notification> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    List<Notification> findByCustomerIdAndReadFalse(Long customerId);

    long countByCustomerIdAndReadFalse(Long customerId);
}
