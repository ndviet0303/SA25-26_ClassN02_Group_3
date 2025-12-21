package com.nozie.movieservice.repository;

import com.nozie.movieservice.model.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Layer 3: Persistence Layer (Repository)
 * 
 * Handles direct interaction with the database (Layer 4).
 * Provides CRUD operations and custom queries for Movie entity.
 * 
 * This layer is ONLY accessible by the Service layer (Layer 2).
 * It should NOT be called directly from the Controller layer.
 */
@Repository
public interface MovieRepository extends JpaRepository<Movie, Long> {

    /**
     * Find movie by slug (unique identifier)
     */
    Optional<Movie> findBySlug(String slug);

    /**
     * Find all movies by type (movie, series, hoathinh, tvshow)
     */
    List<Movie> findByType(String type);

    /**
     * Find all movies by status
     */
    List<Movie> findByStatus(String status);

    /**
     * Find movies by year
     */
    List<Movie> findByYear(Integer year);

    /**
     * Find free movies
     */
    List<Movie> findByIsFreeTrue();

    /**
     * Find top movies by view count (descending)
     */
    List<Movie> findTop10ByOrderByViewDesc();

    /**
     * Find movies by name containing keyword (case-insensitive)
     */
    @Query("SELECT m FROM Movie m WHERE LOWER(m.name) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(m.originName) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Movie> searchByKeyword(@Param("keyword") String keyword);

    /**
     * Find top rated movies by TMDB rating
     */
    @Query("SELECT m FROM Movie m WHERE m.tmdbRating IS NOT NULL ORDER BY m.tmdbRating DESC")
    List<Movie> findTopRated();

    /**
     * Find new releases (movies from recent years)
     */
    @Query("SELECT m FROM Movie m WHERE m.year >= :minYear ORDER BY m.year DESC, m.view DESC")
    List<Movie> findNewReleases(@Param("minYear") Integer minYear);

    /**
     * Check if slug already exists (for validation)
     */
    boolean existsBySlug(String slug);

    /**
     * Count movies by type
     */
    long countByType(String type);
}

