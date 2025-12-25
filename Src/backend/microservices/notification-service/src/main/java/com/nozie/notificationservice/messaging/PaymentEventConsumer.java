package com.nozie.notificationservice.messaging;

import com.nozie.common.event.PaymentSucceededEvent;
import com.nozie.notificationservice.config.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventConsumer {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventConsumer.class);

    @RabbitListener(queues = RabbitMQConfig.QUEUE)
    public void consumePaymentEvent(PaymentSucceededEvent event) {
        log.info("Received payment succeeded event from RabbitMQ: {}", event);

        // TODO: Implement actual notification logic (email, push, etc.)
        log.info("Processing notification for customer {} regarding transaction {}",
                event.getCustomerId(), event.getTransactionId());

        sendMockEmail(event);
    }

    private void sendMockEmail(PaymentSucceededEvent event) {
        log.info("Sending mock email receipt for movie ID {} to customer ID {}",
                event.getMovieId(), event.getCustomerId());
    }
}
