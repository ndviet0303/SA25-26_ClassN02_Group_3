package com.nozie.movieservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * Movie Service - Movie Management Microservice
 * 
 * Provides CRUD operations for movies.
 * Registers with Eureka Discovery Server.
 * 
 * Port: 8081
 */
@SpringBootApplication(scanBasePackages = {"com.nozie.movieservice", "com.nozie.common"})
@EnableDiscoveryClient
@EnableFeignClients
public class MovieServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MovieServiceApplication.class, args);
        System.out.println("🎬 Movie Service is running on port 8081");
    }
}

