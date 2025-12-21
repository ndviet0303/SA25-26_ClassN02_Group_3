package com.nozie.movieservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main entry point for the Movie Microservice.
 * This application demonstrates Layered Architecture with CRUD operations.
 * 
 * Architecture Layers:
 * - Layer 1 (Presentation): MovieController - handles HTTP requests
 * - Layer 2 (Business Logic): MovieService - business rules and validation
 * - Layer 3 (Persistence): MovieRepository - data access layer
 * - Layer 4 (Data): H2/PostgreSQL Database
 */
@SpringBootApplication
public class MovieServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MovieServiceApplication.class, args);
        System.out.println("🎬 Movie Microservice is running!");
        System.out.println("📍 API Base URL: http://localhost:8080/api/movies");
        System.out.println("📊 H2 Console: http://localhost:8080/h2-console");
    }
}

