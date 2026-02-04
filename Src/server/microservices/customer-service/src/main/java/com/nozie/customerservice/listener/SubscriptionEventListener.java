package com.nozie.customerservice.listener;

import com.nozie.common.event.SubscriptionActivatedEvent;
import com.nozie.customerservice.model.Customer;
import com.nozie.customerservice.repository.CustomerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Listener for subscription events from Payment Service
 */
@Component
public class SubscriptionEventListener {

    private static final Logger log = LoggerFactory.getLogger(SubscriptionEventListener.class);

    private final CustomerRepository customerRepository;

    public SubscriptionEventListener(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    /**
     * Xử lý event khi subscription được kích hoạt
     */
    @RabbitListener(queues = "subscription.notification.queue")
    @Transactional
    public void handleSubscriptionActivated(SubscriptionActivatedEvent event) {
        log.info("Received SubscriptionActivatedEvent: {}", event);

        customerRepository.findById(event.getCustomerId())
                .ifPresentOrElse(
                        customer -> {
                            // Determine subscription status based on plan type
                            Customer.SubscriptionStatus status = determineSubscriptionStatus(event.getPlanType());

                            // Activate subscription
                            customer.activateSubscription(
                                    status,
                                    event.getEndDate(),
                                    event.getStripeCustomerId());

                            customerRepository.save(customer);
                            log.info("Customer {} subscription activated: {} until {}",
                                    customer.getId(), status, event.getEndDate());
                        },
                        () -> log.warn("Customer not found with ID: {}", event.getCustomerId()));
    }

    private Customer.SubscriptionStatus determineSubscriptionStatus(String planType) {
        if (planType == null)
            return Customer.SubscriptionStatus.FREE;

        if (planType.startsWith("VIP")) {
            return Customer.SubscriptionStatus.VIP;
        } else if (planType.startsWith("PREMIUM")) {
            return Customer.SubscriptionStatus.PREMIUM;
        }
        return Customer.SubscriptionStatus.FREE;
    }
}
