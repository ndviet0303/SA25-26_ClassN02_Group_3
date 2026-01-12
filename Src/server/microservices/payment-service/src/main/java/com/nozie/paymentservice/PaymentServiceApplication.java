package com.nozie.paymentservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * Payment Service - Payment Processing Microservice
 * 
 * Port: 8083
 */
@SpringBootApplication(scanBasePackages = {"com.nozie.paymentservice", "com.nozie.common"})
@EnableDiscoveryClient
@EnableFeignClients
public class PaymentServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(PaymentServiceApplication.class, args);
        System.out.println("💳 Payment Service is running on port 8083");
    }
}

