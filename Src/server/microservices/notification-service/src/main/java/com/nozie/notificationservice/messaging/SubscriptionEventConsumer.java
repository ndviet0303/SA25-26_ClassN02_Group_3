package com.nozie.notificationservice.messaging;

import com.nozie.common.event.SubscriptionActivatedEvent;
import com.nozie.notificationservice.config.RabbitMQConfig;
import com.nozie.notificationservice.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

/**
 * SubscriptionEventConsumer
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class SubscriptionEventConsumer {

    private final NotificationService notificationService;

    @RabbitListener(queues = RabbitMQConfig.SUBSCRIPTION_QUEUE)
    public void consumeSubscriptionActivatedEvent(SubscriptionActivatedEvent event) {
        log.info("Received SubscriptionActivatedEvent: userId={}, planName={}",
                event.getUserId(), event.getPlanName());

        try {
            // TODO: Need to get customer email from customer-service via Feign client
            // For now, we'll just create in-app notification
            notificationService.createNotification(
                    event.getUserId(),
                    "purchase",
                    "Gói " + event.getPlanName() + " đã được kích hoạt!",
                    "Bạn có thể xem tất cả phim Premium đến ngày " +
                            event.getEndDate().toLocalDate().format(
                                    java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                    "/subscription");

            log.info("Created subscription notification for user {}", event.getUserId());
        } catch (Exception e) {
            log.error("Error processing SubscriptionActivatedEvent: {}", e.getMessage(), e);
        }
    }
}
