package com.nozie.movieservice.service;

import com.nozie.movieservice.dto.MovieDTO;
import com.nozie.movieservice.model.Movie;

import java.util.List;

/**
 * Layer 2: Business Logic Layer (Service Interface)
 * 
 * Defines the contract for movie business operations.
 * Contains business rules, validation logic, and transaction management.
 * 
 * This layer REQUIRES the Repository layer (Layer 3).
 * This layer is REQUIRED BY the Controller layer (Layer 1).
 */
public interface MovieService {

    /**
     * Create a new movie.
     * Business Rules:
     * - Name cannot be empty
     * - Slug must be unique
     * - Price determines if movie is free
     */
    Movie createMovie(MovieDTO movieDTO);

    /**
     * Get all movies.
     */
    List<Movie> getAllMovies();

    /**
     * Get movie by ID.
     * @throws MovieNotFoundException if not found
     */
    Movie getMovieById(Long id);

    /**
     * Get movie by slug.
     * @throws MovieNotFoundException if not found
     */
    Movie getMovieBySlug(String slug);

    /**
     * Update an existing movie.
     * Business Rules:
     * - Movie must exist
     * - Slug must remain unique if changed
     */
    Movie updateMovie(Long id, MovieDTO movieDTO);

    /**
     * Delete a movie.
     * @throws MovieNotFoundException if not found
     */
    void deleteMovie(Long id);

    /**
     * Search movies by keyword.
     */
    List<Movie> searchMovies(String keyword);

    /**
     * Get movies by type.
     */
    List<Movie> getMoviesByType(String type);

    /**
     * Get top trending movies (by view count).
     */
    List<Movie> getTopTrending();

    /**
     * Get new releases.
     */
    List<Movie> getNewReleases();

    /**
     * Get free movies.
     */
    List<Movie> getFreeMovies();

    /**
     * Increment view count for a movie.
     */
    void incrementViewCount(Long id);
}

