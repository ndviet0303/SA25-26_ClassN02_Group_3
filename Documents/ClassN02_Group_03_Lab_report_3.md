# Lab 3: Layered Architecture Implementation (CRUD)

**Course:** Software Architecture  
**Class:** N02  
**Group:** 03  
**Project:** Nozie - Movie Streaming Platform  
**Date:** December 21, 2025

---

This lab focuses on the practical implementation of the **Movie Management** feature using the Layered Architecture designed in Lab 2. We will set up the project structure and code the Create, Read, Update, and Delete (CRUD) operations for a Movie, demonstrating the strict flow of control between the layers.

---

## Objectives

1. Set up a project with distinct packages/modules for the three architectural layers (Presentation, Business Logic, Persistence).
2. Implement the **Movie** entity and the core CRUD operations.
3. Ensure strict dependency flow: Controller → Service → Repository.

---

## Technology & Tool Installation

We use **Java with the Spring Boot** framework, and **H2 in-memory database** to simulate the database in the persistence layer.

| Tool | Purpose | Installation/Setup Guide |
|------|---------|-------------------------|
| Java 21 | Core programming language. | Download and install Java from [Adoptium](https://adoptium.net/). |
| Maven | Build tool and dependency management. | Open your terminal and run: `brew install maven` (macOS) or download from [Maven](https://maven.apache.org/). |
| Spring Boot 3.2.0 | Framework for building the Presentation Layer (Controller/API). | Via Maven dependency in `pom.xml`. |
| H2 Database | In-memory database for Persistence Layer. | Via Maven dependency in `pom.xml`. |
| IDE/Code Editor | Writing and running code (e.g., IntelliJ IDEA, VS Code). | Install your preferred editor. |

---

## Activity Practice 1: Project Setup and Model Definition

**Goal:** Create the basic folder structure and define the data model.

### Step-by-Step Instructions & Coding Guide

**1. Create Project Directory:**

```bash
mkdir nozie-microservices
cd nozie-microservices

# Create movie-service module
mkdir -p movie-service/src/main/java/com/nozie/movieservice
mkdir -p movie-service/src/main/resources
```

**2. Create Layer Folders/Modules:** Create the necessary subdirectories to represent the layers and the core application files.

```bash
cd movie-service/src/main/java/com/nozie/movieservice

mkdir controller    # Presentation Layer
mkdir service       # Business Logic Layer  
mkdir repository    # Persistence Layer
mkdir model         # Data Model
mkdir dto           # Data Transfer Objects
```

**Project Structure:**

```
movie-service/
├── src/main/java/com/nozie/movieservice/
│   ├── MovieServiceApplication.java    # Main entry point
│   ├── controller/                      # Presentation Layer
│   ├── service/                         # Business Logic Layer
│   ├── repository/                      # Persistence Layer
│   ├── model/                           # Data Model
│   └── dto/                             # DTOs
├── src/main/resources/
│   └── application.yml                  # Configuration
└── pom.xml                              # Dependencies
```

**3. Define the Movie Model:** This defines the basic structure of the data object passed between layers.

**File:** `model/Movie.java`

```java
package com.nozie.movieservice.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Defines the core data structure used throughout the application
 */
@Entity
@Table(name = "movies")
public class Movie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Movie name is required")
    @Column(nullable = false)
    private String name;

    @NotBlank(message = "Slug is required")
    @Column(unique = true, nullable = false)
    private String slug;

    private String type;
    private String status;
    private String quality;
    
    @Column(name = "\"year\"")
    private Integer year;

    private Long view = 0L;

    @Column(precision = 10, scale = 2)
    private BigDecimal price = BigDecimal.ZERO;

    @Column(name = "is_free")
    private Boolean isFree = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    // Constructor
    public Movie() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public Boolean getIsFree() { return isFree; }
    public void setIsFree(Boolean isFree) { this.isFree = isFree; }
    
    // ... other getters/setters
}
```

---

## Activity Practice 2: Persistence Layer (Repository)

**Goal:** Implement the component that interacts directly with the data store (H2 in-memory database).

### Step-by-Step Instructions & Coding Guide

**1. Implement the Repository:** Create an interface that handles data access. This layer is unaware of HTTP or business rules.

**File:** `repository/MovieRepository.java`

```java
package com.nozie.movieservice.repository;

import com.nozie.movieservice.model.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Layer 3: Handles basic CRUD operations directly on the data store.
 * Extends JpaRepository which provides built-in methods: save(), findAll(), findById(), deleteById()
 */
@Repository
public interface MovieRepository extends JpaRepository<Movie, Long> {

    // Find movie by slug
    Optional<Movie> findBySlug(String slug);

    // Find movies by type
    List<Movie> findByType(String type);

    // Check if slug exists
    boolean existsBySlug(String slug);

    // Search movies by keyword
    @Query("SELECT m FROM Movie m WHERE LOWER(m.name) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Movie> searchByKeyword(@Param("keyword") String keyword);
}
```

**Key Methods Provided by JpaRepository:**

| Method | Description |
|--------|-------------|
| `save(entity)` | Create or Update entity |
| `findAll()` | Returns a list of all entities |
| `findById(id)` | Find entity by ID |
| `existsById(id)` | Check if entity exists |
| `deleteById(id)` | Delete entity by ID |

---

## Activity Practice 3: Business Logic Layer (Service)

**Goal:** Implement the component that encapsulates the business rules and orchestrates calls to the Persistence Layer.

### Step-by-Step Instructions & Coding Guide

**1. Implement the Service:** Create a class that provides the core business functions, using the Repository to access data.

**File:** `service/MovieService.java`

```java
package com.nozie.movieservice.service;

import com.nozie.movieservice.dto.MovieRequest;
import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.repository.MovieRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * Layer 2: Handles business rules, validation, and transaction logic.
 * The Service layer requires (needs) the Repository layer.
 */
@Service
@Transactional
public class MovieService {

    // Instantiate the Repository to use its methods
    private final MovieRepository movieRepository;

    public MovieService(MovieRepository movieRepository) {
        this.movieRepository = movieRepository;
    }

    /**
     * CREATE - Business Rule: Slug must be unique
     */
    public Movie createMovie(MovieRequest request) {
        // Business Rule: Movie slug must be unique
        if (movieRepository.existsBySlug(request.getSlug())) {
            throw new RuntimeException("Movie with slug '" + request.getSlug() + "' already exists");
        }

        Movie movie = new Movie();
        movie.setName(request.getName());
        movie.setSlug(request.getSlug());
        movie.setType(request.getType());
        movie.setYear(request.getYear());
        movie.setPrice(request.getPrice() != null ? request.getPrice() : BigDecimal.ZERO);
        
        // Business Rule: Set isFree based on price
        movie.setIsFree(movie.getPrice().compareTo(BigDecimal.ZERO) <= 0);

        // Call the Persistence Layer (Strict downward flow)
        return movieRepository.save(movie);
    }

    /**
     * READ ALL
     */
    @Transactional(readOnly = true)
    public List<Movie> getAllMovies() {
        return movieRepository.findAll();
    }

    /**
     * READ BY ID - Business Rule: Throw exception if not found
     */
    @Transactional(readOnly = true)
    public Movie getMovieById(Long id) {
        return movieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Movie with ID " + id + " not found"));
    }

    /**
     * UPDATE - Business Rules: Check existence, validate unique slug
     */
    public Movie updateMovie(Long id, MovieRequest request) {
        Movie movie = getMovieById(id);

        // Business Rule: If changing slug, ensure new slug is unique
        if (!movie.getSlug().equals(request.getSlug()) && 
            movieRepository.existsBySlug(request.getSlug())) {
            throw new RuntimeException("Movie with slug '" + request.getSlug() + "' already exists");
        }

        movie.setName(request.getName());
        movie.setSlug(request.getSlug());
        movie.setType(request.getType());
        movie.setYear(request.getYear());
        movie.setPrice(request.getPrice() != null ? request.getPrice() : BigDecimal.ZERO);
        movie.setIsFree(movie.getPrice().compareTo(BigDecimal.ZERO) <= 0);

        return movieRepository.save(movie);
    }

    /**
     * DELETE - Business Rule: Verify existence before deletion
     */
    public void deleteMovie(Long id) {
        if (!movieRepository.existsById(id)) {
            throw new RuntimeException("Movie with ID " + id + " not found");
        }
        movieRepository.deleteById(id);
    }
}
```

---

## Activity Practice 4: Presentation Layer (Controller/API)

**Goal:** Implement the component that handles HTTP requests, calls the Service Layer, and formats the response.

### Step-by-Step Instructions & Coding Guide

**1. Implement the Controller (Spring Boot REST API):** This layer requires the Service Layer.

**File:** `controller/MovieController.java`

```java
package com.nozie.movieservice.controller;

import com.nozie.movieservice.dto.MovieRequest;
import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.service.MovieService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Layer 1: Presentation Layer - Handles HTTP requests and responses.
 * The Controller layer requires (needs) the Service layer.
 */
@RestController
@RequestMapping("/api/movies")
public class MovieController {

    // The Controller requires the Service layer (NOT Repository directly!)
    private final MovieService movieService;

    public MovieController(MovieService movieService) {
        this.movieService = movieService;
    }

    /**
     * CREATE - POST /api/movies
     */
    @PostMapping
    public ResponseEntity<?> createMovie(@Valid @RequestBody MovieRequest request) {
        // Layer 1: Handles request input and delegates to Layer 2
        try {
            Movie movie = movieService.createMovie(request);
            // Layer 1: Formats response for client
            return ResponseEntity.status(HttpStatus.CREATED).body(movie);
        } catch (RuntimeException e) {
            // Layer 1: Handles exceptions raised by Layer 2 and formats error response
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * READ ALL - GET /api/movies
     */
    @GetMapping
    public ResponseEntity<List<Movie>> getAllMovies() {
        // Layer 1: Delegates request to Layer 2
        List<Movie> movies = movieService.getAllMovies();
        return ResponseEntity.ok(movies);
    }

    /**
     * READ BY ID - GET /api/movies/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getMovieById(@PathVariable Long id) {
        try {
            Movie movie = movieService.getMovieById(id);
            return ResponseEntity.ok(movie);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * UPDATE - PUT /api/movies/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateMovie(@PathVariable Long id, 
                                         @Valid @RequestBody MovieRequest request) {
        try {
            Movie movie = movieService.updateMovie(id, request);
            return ResponseEntity.ok(movie);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * DELETE - DELETE /api/movies/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMovie(@PathVariable Long id) {
        try {
            movieService.deleteMovie(id);
            return ResponseEntity.ok(Map.of("message", "Movie deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}
```

**2. Run and Test:**

- **Action:** Run the application from your terminal:

```bash
cd movie-service
mvn spring-boot:run
```

- **Action:** Use a tool like Postman or curl to test the endpoints:

**Create Movie (POST):**
```bash
curl -X POST http://localhost:8081/api/movies \
  -H "Content-Type: application/json" \
  -d '{"name": "Inception", "slug": "inception", "year": 2010, "type": "movie"}'
```

**Response:**
```json
{
  "id": 1,
  "name": "Inception",
  "slug": "inception",
  "type": "movie",
  "year": 2010,
  "isFree": true,
  "createdAt": "2025-12-21T10:30:17.723134"
}
```

**Get All Movies (GET):**
```bash
curl http://localhost:8081/api/movies
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Inception",
    "slug": "inception",
    "type": "movie",
    "year": 2010,
    "isFree": true
  }
]
```

**Get Movie by ID (GET):**
```bash
curl http://localhost:8081/api/movies/1
```

**Update Movie (PUT):**
```bash
curl -X PUT http://localhost:8081/api/movies/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "Inception (Updated)", "slug": "inception", "year": 2010, "type": "movie"}'
```

**Delete Movie (DELETE):**
```bash
curl -X DELETE http://localhost:8081/api/movies/1
```

**Response:**
```json
{
  "message": "Movie deleted successfully"
}
```

---

## Summary

The system now demonstrates the **Layered Architecture**, where each layer is responsible for its domain, and control flows strictly downward:

```
┌─────────────────────────────────────────────────────────────┐
│                  LAYERED ARCHITECTURE FLOW                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   HTTP Request                                              │
│        │                                                    │
│        ▼                                                    │
│   ┌─────────────────────────────────────────┐              │
│   │  Layer 1: CONTROLLER (MovieController)  │              │
│   │  - Handles HTTP requests/responses      │              │
│   │  - Input validation                     │              │
│   │  - Error formatting                     │              │
│   └─────────────────┬───────────────────────┘              │
│                     │ @Autowired                            │
│                     ▼                                       │
│   ┌─────────────────────────────────────────┐              │
│   │  Layer 2: SERVICE (MovieService)        │              │
│   │  - Business rules & validation          │              │
│   │  - Transaction management               │              │
│   │  - Orchestrates data operations         │              │
│   └─────────────────┬───────────────────────┘              │
│                     │ @Autowired                            │
│                     ▼                                       │
│   ┌─────────────────────────────────────────┐              │
│   │  Layer 3: REPOSITORY (MovieRepository)  │              │
│   │  - CRUD operations on database          │              │
│   │  - Data access abstraction              │              │
│   └─────────────────┬───────────────────────┘              │
│                     │ JPA/Hibernate                         │
│                     ▼                                       │
│   ┌─────────────────────────────────────────┐              │
│   │  Layer 4: DATABASE (H2 In-Memory)       │              │
│   │  - Data storage                         │              │
│   └─────────────────────────────────────────┘              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

| Layer | Component | Responsibility |
|-------|-----------|----------------|
| Layer 1 | `MovieController` | HTTP handling, request/response formatting |
| Layer 2 | `MovieService` | Business rules, validation, transactions |
| Layer 3 | `MovieRepository` | Data access operations (CRUD) |
| Layer 4 | H2 Database | Data storage |

**Dependency Flow:** Controller → Service → Repository (Strict downward flow, no skipping layers)

---

**Submitted by:** Group 03  
**Course:** Software Architecture (N02)
