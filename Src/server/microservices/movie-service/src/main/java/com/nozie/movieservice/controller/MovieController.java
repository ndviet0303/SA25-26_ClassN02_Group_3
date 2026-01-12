package com.nozie.movieservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.movieservice.dto.MovieRequest;
import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.service.MovieService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 1: Presentation Layer - Movie Controller
 */
@RestController
@RequestMapping("/api/movies")
@CrossOrigin(origins = "*")
public class MovieController {

    private static final Logger log = LoggerFactory.getLogger(MovieController.class);

    private final MovieService movieService;

    public MovieController(MovieService movieService) {
        this.movieService = movieService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Movie>> createMovie(@Valid @RequestBody MovieRequest request) {
        log.info("POST /api/movies - Creating movie: {}", request.getName());
        Movie movie = movieService.createMovie(request);
        return new ResponseEntity<>(ApiResponse.success("Movie created successfully", movie), HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Movie>>> getAllMovies() {
        log.info("GET /api/movies - Fetching all movies");
        List<Movie> movies = movieService.getAllMovies();
        return ResponseEntity.ok(ApiResponse.success(movies));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Movie>> getMovieById(@PathVariable String id) {
        log.info("GET /api/movies/{} - Fetching movie by ID", id);
        Movie movie = movieService.getMovieById(id);
        return ResponseEntity.ok(ApiResponse.success(movie));
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<ApiResponse<Movie>> getMovieBySlug(@PathVariable String slug) {
        log.info("GET /api/movies/slug/{} - Fetching movie by slug", slug);
        Movie movie = movieService.getMovieBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(movie));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Movie>> updateMovie(@PathVariable String id,
            @Valid @RequestBody MovieRequest request) {
        log.info("PUT /api/movies/{} - Updating movie", id);
        Movie movie = movieService.updateMovie(id, request);
        return ResponseEntity.ok(ApiResponse.success("Movie updated successfully", movie));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteMovie(@PathVariable String id) {
        log.info("DELETE /api/movies/{} - Deleting movie", id);
        movieService.deleteMovie(id);
        return ResponseEntity.ok(ApiResponse.success("Movie deleted successfully", null));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<Movie>>> searchMovies(@RequestParam(name = "q") String keyword) {
        log.info("GET /api/movies/search?q={} - Searching movies", keyword);
        List<Movie> movies = movieService.searchMovies(keyword);
        return ResponseEntity.ok(ApiResponse.success(movies));
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<List<Movie>>> getMoviesByType(@PathVariable String type) {
        log.info("GET /api/movies/type/{} - Fetching movies by type", type);
        List<Movie> movies = movieService.getMoviesByType(type);
        return ResponseEntity.ok(ApiResponse.success(movies));
    }

    @GetMapping("/trending")
    public ResponseEntity<ApiResponse<List<Movie>>> getTrendingMovies() {
        log.info("GET /api/movies/trending - Fetching trending movies");
        List<Movie> movies = movieService.getTrendingMovies();
        return ResponseEntity.ok(ApiResponse.success(movies));
    }

    @GetMapping("/free")
    public ResponseEntity<ApiResponse<List<Movie>>> getFreeMovies() {
        log.info("GET /api/movies/free - Fetching free movies");
        List<Movie> movies = movieService.getFreeMovies();
        return ResponseEntity.ok(ApiResponse.success(movies));
    }

    @PostMapping("/{id}/view")
    public ResponseEntity<ApiResponse<Void>> incrementViewCount(@PathVariable String id) {
        log.info("POST /api/movies/{}/view - Incrementing view count", id);
        movieService.incrementViewCount(id);
        return ResponseEntity.ok(ApiResponse.success("View count incremented", null));
    }
}
