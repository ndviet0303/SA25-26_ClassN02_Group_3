package com.nozie.movieservice.controller;

import com.nozie.movieservice.dto.MovieDTO;
import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.service.MovieService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 1: Presentation Layer (Controller)
 * 
 * Handles HTTP requests, delegates to Service Layer, and formats responses.
 * 
 * Key Responsibilities:
 * - Receive and validate HTTP requests
 * - Call Service layer (Layer 2)
 * - Format and return HTTP responses
 * 
 * Strict Dependency Flow: Controller → Service → Repository
 * 
 * API Endpoints:
 * - POST   /api/movies          - Create movie
 * - GET    /api/movies          - Get all movies
 * - GET    /api/movies/{id}     - Get movie by ID
 * - GET    /api/movies/slug/{slug} - Get movie by slug
 * - PUT    /api/movies/{id}     - Update movie
 * - DELETE /api/movies/{id}     - Delete movie
 * - GET    /api/movies/search   - Search movies
 * - GET    /api/movies/type/{type} - Get movies by type
 * - GET    /api/movies/trending - Get trending movies
 * - GET    /api/movies/new      - Get new releases
 * - GET    /api/movies/free     - Get free movies
 * - POST   /api/movies/{id}/view - Increment view count
 */
@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class MovieController {

    // Dependency on Layer 2 (Business Logic Layer)
    private final MovieService movieService;

    /**
     * CREATE: Create a new movie
     * POST /api/movies
     */
    @PostMapping
    public ResponseEntity<Movie> createMovie(@Valid @RequestBody MovieDTO movieDTO) {
        log.info("REST request to create movie: {}", movieDTO.getName());

        // Delegate to Service Layer (Layer 2)
        Movie createdMovie = movieService.createMovie(movieDTO);

        // Format response (201 Created)
        return new ResponseEntity<>(createdMovie, HttpStatus.CREATED);
    }

    /**
     * READ: Get all movies
     * GET /api/movies
     */
    @GetMapping
    public ResponseEntity<List<Movie>> getAllMovies() {
        log.info("REST request to get all movies");

        // Delegate to Service Layer (Layer 2)
        List<Movie> movies = movieService.getAllMovies();

        // Format response (200 OK)
        return ResponseEntity.ok(movies);
    }

    /**
     * READ: Get movie by ID
     * GET /api/movies/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<Movie> getMovieById(@PathVariable Long id) {
        log.info("REST request to get movie by ID: {}", id);

        // Delegate to Service Layer (Layer 2)
        Movie movie = movieService.getMovieById(id);

        // Format response (200 OK)
        return ResponseEntity.ok(movie);
    }

    /**
     * READ: Get movie by slug
     * GET /api/movies/slug/{slug}
     */
    @GetMapping("/slug/{slug}")
    public ResponseEntity<Movie> getMovieBySlug(@PathVariable String slug) {
        log.info("REST request to get movie by slug: {}", slug);

        // Delegate to Service Layer (Layer 2)
        Movie movie = movieService.getMovieBySlug(slug);

        // Format response (200 OK)
        return ResponseEntity.ok(movie);
    }

    /**
     * UPDATE: Update an existing movie
     * PUT /api/movies/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<Movie> updateMovie(
            @PathVariable Long id,
            @Valid @RequestBody MovieDTO movieDTO) {
        log.info("REST request to update movie ID: {}", id);

        // Delegate to Service Layer (Layer 2)
        Movie updatedMovie = movieService.updateMovie(id, movieDTO);

        // Format response (200 OK)
        return ResponseEntity.ok(updatedMovie);
    }

    /**
     * DELETE: Delete a movie
     * DELETE /api/movies/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMovie(@PathVariable Long id) {
        log.info("REST request to delete movie ID: {}", id);

        // Delegate to Service Layer (Layer 2)
        movieService.deleteMovie(id);

        // Format response (204 No Content)
        return ResponseEntity.noContent().build();
    }

    /**
     * SEARCH: Search movies by keyword
     * GET /api/movies/search?q={keyword}
     */
    @GetMapping("/search")
    public ResponseEntity<List<Movie>> searchMovies(@RequestParam(name = "q") String keyword) {
        log.info("REST request to search movies with keyword: {}", keyword);

        // Delegate to Service Layer (Layer 2)
        List<Movie> movies = movieService.searchMovies(keyword);

        // Format response (200 OK)
        return ResponseEntity.ok(movies);
    }

    /**
     * FILTER: Get movies by type
     * GET /api/movies/type/{type}
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<Movie>> getMoviesByType(@PathVariable String type) {
        log.info("REST request to get movies by type: {}", type);

        // Delegate to Service Layer (Layer 2)
        List<Movie> movies = movieService.getMoviesByType(type);

        // Format response (200 OK)
        return ResponseEntity.ok(movies);
    }

    /**
     * TRENDING: Get top trending movies
     * GET /api/movies/trending
     */
    @GetMapping("/trending")
    public ResponseEntity<List<Movie>> getTopTrending() {
        log.info("REST request to get trending movies");

        // Delegate to Service Layer (Layer 2)
        List<Movie> movies = movieService.getTopTrending();

        // Format response (200 OK)
        return ResponseEntity.ok(movies);
    }

    /**
     * NEW RELEASES: Get new release movies
     * GET /api/movies/new
     */
    @GetMapping("/new")
    public ResponseEntity<List<Movie>> getNewReleases() {
        log.info("REST request to get new releases");

        // Delegate to Service Layer (Layer 2)
        List<Movie> movies = movieService.getNewReleases();

        // Format response (200 OK)
        return ResponseEntity.ok(movies);
    }

    /**
     * FREE: Get free movies
     * GET /api/movies/free
     */
    @GetMapping("/free")
    public ResponseEntity<List<Movie>> getFreeMovies() {
        log.info("REST request to get free movies");

        // Delegate to Service Layer (Layer 2)
        List<Movie> movies = movieService.getFreeMovies();

        // Format response (200 OK)
        return ResponseEntity.ok(movies);
    }

    /**
     * VIEW COUNT: Increment view count
     * POST /api/movies/{id}/view
     */
    @PostMapping("/{id}/view")
    public ResponseEntity<Void> incrementViewCount(@PathVariable Long id) {
        log.info("REST request to increment view count for movie ID: {}", id);

        // Delegate to Service Layer (Layer 2)
        movieService.incrementViewCount(id);

        // Format response (200 OK)
        return ResponseEntity.ok().build();
    }
}

