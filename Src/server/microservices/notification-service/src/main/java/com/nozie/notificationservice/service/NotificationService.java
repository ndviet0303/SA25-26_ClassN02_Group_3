package com.nozie.notificationservice.service;

import com.nozie.notificationservice.model.Notification;
import com.nozie.notificationservice.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * NotificationService
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class NotificationService {

        private final NotificationRepository notificationRepository;
        private final EmailService emailService;

        /**
         *  in-app notification
         */
        public Notification createNotification(Long customerId, String type, String title, String description) {
                return createNotification(customerId, type, title, description, null);
        }

        /**
         *  in-app notification với deep link
         */
        public Notification createNotification(Long customerId, String type, String title, String description,
                        String deepLink) {
                log.info("Creating notification for customer {}: {}", customerId, title);

                Notification notification = Notification.builder()
                                .customerId(customerId)
                                .type(type)
                                .title(title)
                                .description(description)
                                .deepLink(deepLink)
                                .build();

                return notificationRepository.save(notification);
        }

        /**
         * Xử lý user mới đăng ký - gửi email + tạo notification
         */
        public void handleUserRegistered(Long customerId, String email, String fullName) {
                log.info("Handling user registered: {} ({})", fullName, email);

                // 1. Gửi email chào mừng
                emailService.sendWelcomeEmail(email, fullName);

                // 2. Tạo in-app notification
                createNotification(
                                customerId,
                                "system",
                                "Welcome to Nozie!",
                                "Explore thousands of movies waiting for you.",
                                "/explore");
        }

        /**
         * Xử lý subscription được kích hoạt - gửi email + tạo notification
         */
        public void handleSubscriptionActivated(Long customerId, String email, String fullName,
                        String planName, java.time.LocalDate endDate) {
                log.info("Handling subscription activated for customer {}: {}", customerId, planName);

                // 1. Gửi email xác nhận
                emailService.sendSubscriptionActivatedEmail(email, fullName, planName, endDate);

                // 2. Tạo in-app notification
                createNotification(
                                customerId,
                                "purchase",
                                "Plan " + planName + " activated!",
                                "You can watch all Premium movies until " +
                                                endDate.format(java.time.format.DateTimeFormatter
                                                                .ofPattern("MM/dd/yyyy")),
                                "/subscription");
        }

        /**
         * Xử lý subscription sắp hết hạn - gửi email nhắc nhở
         */
        public void handleSubscriptionExpiring(Long customerId, String email, String fullName,
                        String planName, int daysLeft) {
                log.info("Handling subscription expiring for customer {}: {} days left", customerId, daysLeft);

                // 1. Gửi email nhắc nhở
                emailService.sendSubscriptionExpiringEmail(email, fullName, planName, daysLeft);

                // 2. Tạo in-app notification
                createNotification(
                                customerId,
                                "system",
                                "Plan " + planName + " expiring soon!",
                                "Only " + daysLeft + " days left. Renew now to stay premium.",
                                "/subscription/renew");
        }
}
