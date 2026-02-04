package com.nozie.notificationservice.messaging;

import com.nozie.common.event.UserRegisteredEvent;
import com.nozie.notificationservice.config.RabbitMQConfig;
import com.nozie.notificationservice.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

/**
 * UserEventConsumer
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class UserEventConsumer {

    private final NotificationService notificationService;

    @RabbitListener(queues = RabbitMQConfig.USER_QUEUE)
    public void consumeUserRegisteredEvent(UserRegisteredEvent event) {
        log.info("Received UserRegisteredEvent: userId={}, email={}",
                event.getUserId(), event.getEmail());

        try {
            notificationService.handleUserRegistered(
                    event.getUserId(),
                    event.getEmail(),
                    event.getFullName() != null ? event.getFullName() : event.getUsername());
            log.info("Successfully processed welcome notification for user {}", event.getUserId());
        } catch (Exception e) {
            log.error("Error processing UserRegisteredEvent: {}", e.getMessage(), e);
        }
    }
}
