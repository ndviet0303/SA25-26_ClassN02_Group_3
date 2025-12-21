package com.nozie.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * API Gateway - Single Entry Point for all microservices
 * 
 * Routes:
 * - /api/movies/** -> movie-service
 * - /api/customers/** -> customer-service
 * - /api/payments/** -> payment-service
 * - /api/notifications/** -> notification-service
 * 
 * Port: 8080
 */
@SpringBootApplication
@EnableDiscoveryClient
public class ApiGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
        System.out.println("🚪 API Gateway is running on port 8080");
        System.out.println("📡 Routes:");
        System.out.println("   /api/movies/** -> movie-service");
        System.out.println("   /api/customers/** -> customer-service");
        System.out.println("   /api/payments/** -> payment-service");
        System.out.println("   /api/notifications/** -> notification-service");
    }
}

