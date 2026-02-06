package com.nozie.customerservice.listener;

import com.nozie.common.event.UserRegisteredEvent;
import com.nozie.customerservice.config.MessagingConfig;
import com.nozie.customerservice.dto.CustomerInterestRequest;
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
            // Build customer with all profile info
            CustomerRequest request = CustomerRequest.builder()
                    .userId(event.getUserId())
                    .fullName(event.getFullName())
                    .phoneNumber(event.getPhoneNumber())
                    .dateOfBirth(event.getDateOfBirth())
                    .gender(event.getGender())
                    .country(event.getCountry())
                    .avatarUrl(event.getAvatarUrl())
                    .bio(event.getBio())
                    .build();

            var customer = customerService.createCustomer(request);
            log.info("Successfully created customer record for user ID: {}", event.getUserId());

            // Set initial interests if provided
            if (event.getGenres() != null && !event.getGenres().isEmpty()) {
                CustomerInterestRequest interestRequest = new CustomerInterestRequest();
                interestRequest.setGenreSlugs(event.getGenres());
                customerService.setInterests(customer.getId(), interestRequest);
                log.info("Set {} initial interests for customer ID: {}", event.getGenres().size(), customer.getId());
            }
        } catch (Exception e) {
            log.error("Failed to create customer record for user ID: {}. Error: {}",
                    event.getUserId(), e.getMessage());
        }
    }
}
