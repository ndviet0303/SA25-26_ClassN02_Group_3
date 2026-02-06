package com.nozie.notificationservice.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    // Payment events
    public static final String PAYMENT_EXCHANGE = "payment.exchange";
    public static final String PAYMENT_QUEUE = "notification.payment.queue";
    public static final String PAYMENT_ROUTING_KEY = "payment.succeeded";

    // User events
    public static final String USER_EXCHANGE = "user.exchange";
    public static final String USER_QUEUE = "notification.user.queue";
    public static final String USER_ROUTING_KEY = "user.registered";

    // Legacy alias
    public static final String EXCHANGE = PAYMENT_EXCHANGE;
    public static final String QUEUE = PAYMENT_QUEUE;
    public static final String ROUTING_KEY = PAYMENT_ROUTING_KEY;

    @Bean
    public TopicExchange paymentExchange() {
        return new TopicExchange(PAYMENT_EXCHANGE);
    }

    @Bean
    public Queue paymentQueue() {
        return new Queue(PAYMENT_QUEUE);
    }

    @Bean
    public Binding paymentBinding(Queue paymentQueue, TopicExchange paymentExchange) {
        return BindingBuilder.bind(paymentQueue).to(paymentExchange).with(PAYMENT_ROUTING_KEY);
    }

    // Subscription events (same exchange as payment)
    public static final String SUBSCRIPTION_QUEUE = "notification.subscription.queue";
    public static final String SUBSCRIPTION_ROUTING_KEY = "subscription.activated";

    @Bean
    public TopicExchange userExchange() {
        return new TopicExchange(USER_EXCHANGE);
    }

    @Bean
    public Queue userQueue() {
        return new Queue(USER_QUEUE);
    }

    @Bean
    public Binding userBinding(Queue userQueue, TopicExchange userExchange) {
        return BindingBuilder.bind(userQueue).to(userExchange).with(USER_ROUTING_KEY);
    }

    @Bean
    public Queue subscriptionQueue() {
        return new Queue(SUBSCRIPTION_QUEUE);
    }

    @Bean
    public Binding subscriptionBinding(Queue subscriptionQueue, TopicExchange paymentExchange) {
        return BindingBuilder.bind(subscriptionQueue).to(paymentExchange).with(SUBSCRIPTION_ROUTING_KEY);
    }

    @Bean
    public MessageConverter converter() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        return new Jackson2JsonMessageConverter(objectMapper);
    }
}
