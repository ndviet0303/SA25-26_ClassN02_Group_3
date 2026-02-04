package com.nozie.paymentservice.infrastructure.messaging;

import com.nozie.common.event.SubscriptionActivatedEvent;
import com.nozie.paymentservice.infrastructure.config.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventProducer {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventProducer.class);

    private final RabbitTemplate rabbitTemplate;

    public PaymentEventProducer(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void sendSubscriptionActivatedEvent(SubscriptionActivatedEvent event) {
        log.info("Sending subscription activated event to RabbitMQ: {}", event);
        rabbitTemplate.convertAndSend(RabbitMQConfig.EXCHANGE, RabbitMQConfig.SUBSCRIPTION_ROUTING_KEY, event);
    }
}
