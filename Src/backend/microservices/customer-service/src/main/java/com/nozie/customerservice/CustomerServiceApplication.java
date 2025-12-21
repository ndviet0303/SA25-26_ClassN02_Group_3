package com.nozie.customerservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * Customer Service - Customer Management Microservice
 * 
 * Port: 8082
 */
@SpringBootApplication(scanBasePackages = {"com.nozie.customerservice", "com.nozie.common"})
@EnableDiscoveryClient
@EnableFeignClients
public class CustomerServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(CustomerServiceApplication.class, args);
        System.out.println("👤 Customer Service is running on port 8082");
    }
}

