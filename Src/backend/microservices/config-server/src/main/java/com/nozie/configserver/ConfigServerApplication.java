package com.nozie.configserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

/**
 * Config Server - Centralized Configuration Management
 * 
 * Provides centralized configuration for all microservices.
 * Configurations are stored in /config folder (native profile).
 * 
 * Port: 8888
 */
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
        System.out.println("⚙️ Config Server is running on port 8888");
    }
}

