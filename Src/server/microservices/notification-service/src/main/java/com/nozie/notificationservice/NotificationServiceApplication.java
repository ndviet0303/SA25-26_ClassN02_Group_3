package com.nozie.notificationservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Notification Service - Notification Microservice
 * 
 * Port: 8084
 */
@SpringBootApplication(scanBasePackages = {"com.nozie.notificationservice", "com.nozie.common"})
@EnableDiscoveryClient
public class NotificationServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(NotificationServiceApplication.class, args);
        System.out.println("🔔 Notification Service is running on port 8084");
    }
}

