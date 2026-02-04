package com.nozie.customerservice.listener;

import com.nozie.common.event.UserRegisteredEvent;
import com.nozie.customerservice.config.MessagingConfig;
import com.nozie.customerservice.dto.CustomerRequest;
import com.nozie.customerservice.service.CustomerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
@RequiredArgsConstructor
public class UserRegisteredListener {

    private final CustomerService customerService;

    @RabbitListener(queues = MessagingConfig.USER_REGISTERED_QUEUE)
    public void handleUserRegistered(UserRegisteredEvent event) {
        log.info("Received UserRegisteredEvent: {}", event);

        try {
            CustomerRequest request = CustomerRequest.builder()
                    .userId(event.getUserId())
                    .email(event.getEmail())
                    .fullName(event.getFullName())
                    .build();

            customerService.createCustomer(request);
            log.info("Successfully created customer record for user ID: {}", event.getUserId());
        } catch (Exception e) {
            log.error("Failed to create customer record for user ID: {}. Error: {}",
                    event.getUserId(), e.getMessage());
        }
    }
}
