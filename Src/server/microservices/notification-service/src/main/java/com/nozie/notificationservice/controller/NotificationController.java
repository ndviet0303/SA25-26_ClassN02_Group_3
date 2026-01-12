package com.nozie.notificationservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.notificationservice.model.Notification;
import com.nozie.notificationservice.repository.NotificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Layer 1: Presentation Layer - Notification Controller
 */
@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    private static final Logger log = LoggerFactory.getLogger(NotificationController.class);

    private final NotificationRepository notificationRepository;

    public NotificationController(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @GetMapping("/{customerId}")
    public ResponseEntity<ApiResponse<List<Notification>>> getNotifications(@PathVariable Long customerId) {
        log.info("GET /api/notifications/{} - Fetching notifications", customerId);
        List<Notification> notifications = notificationRepository.findByCustomerIdOrderByCreatedAtDesc(customerId);
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    @GetMapping("/{customerId}/unread")
    public ResponseEntity<ApiResponse<List<Notification>>> getUnreadNotifications(@PathVariable Long customerId) {
        log.info("GET /api/notifications/{}/unread - Fetching unread notifications", customerId);
        List<Notification> notifications = notificationRepository.findByCustomerIdAndReadFalse(customerId);
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    @GetMapping("/{customerId}/count")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUnreadCount(@PathVariable Long customerId) {
        log.info("GET /api/notifications/{}/count - Getting unread count", customerId);
        long count = notificationRepository.countByCustomerIdAndReadFalse(customerId);
        return ResponseEntity.ok(ApiResponse.success(Map.of("unreadCount", count)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Notification>> createNotification(@RequestBody Notification notification) {
        log.info("POST /api/notifications - Creating notification for customer: {}", notification.getCustomerId());
        Notification saved = notificationRepository.save(notification);
        return new ResponseEntity<>(ApiResponse.success("Notification created", saved), HttpStatus.CREATED);
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Notification>> markAsRead(@PathVariable String id) {
        log.info("PATCH /api/notifications/{}/read - Marking as read", id);
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        notification.setRead(true);
        notificationRepository.save(notification);
        return ResponseEntity.ok(ApiResponse.success("Marked as read", notification));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteNotification(@PathVariable String id) {
        log.info("DELETE /api/notifications/{} - Deleting notification", id);
        notificationRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Notification deleted", null));
    }
}
