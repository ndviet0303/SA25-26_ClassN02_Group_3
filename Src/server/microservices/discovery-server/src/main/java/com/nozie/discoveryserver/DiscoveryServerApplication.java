package com.nozie.discoveryserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * Discovery Server - Service Registry (Eureka)
 * 
 * Manages service registration and discovery.
 * All microservices register here and can discover each other.
 * 
 * Port: 8761
 * Dashboard: http://localhost:8761
 */
@SpringBootApplication
@EnableEurekaServer
public class DiscoveryServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(DiscoveryServerApplication.class, args);
        System.out.println("🔍 Discovery Server (Eureka) is running on port 8761");
        System.out.println("📊 Dashboard: http://localhost:8761");
    }
}

