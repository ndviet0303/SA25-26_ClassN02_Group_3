package com.nozie.movieservice.service.impl;

import com.nozie.movieservice.dto.MovieDTO;
import com.nozie.movieservice.exception.DuplicateSlugException;
import com.nozie.movieservice.exception.MovieNotFoundException;
import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.repository.MovieRepository;
import com.nozie.movieservice.service.MovieService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Layer 2: Business Logic Layer (Service Implementation)
 * 
 * Implements business rules and orchestrates calls to the Persistence Layer.
 * 
 * Key Responsibilities:
 * - Validate business rules
 * - Transform DTOs to Entities
 * - Handle transactions
 * - Call Repository layer (Layer 3)
 * 
 * Strict Dependency Flow: Controller → Service → Repository
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class MovieServiceImpl implements MovieService {

    // Dependency on Layer 3 (Persistence Layer)
    private final MovieRepository movieRepository;

    @Override
    public Movie createMovie(MovieDTO dto) {
        log.info("Creating movie: {}", dto.getName());

        // Business Rule: Validate name is not empty
        if (dto.getName() == null || dto.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Movie name cannot be empty");
        }

        // Business Rule: Validate slug is unique
        if (movieRepository.existsBySlug(dto.getSlug())) {
            throw new DuplicateSlugException(dto.getSlug());
        }

        // Transform DTO to Entity
        Movie movie = mapDtoToEntity(dto, new Movie());

        // Business Rule: Set isFree based on price
        movie.setIsFree(movie.getPrice() == null || 
                        movie.getPrice().compareTo(BigDecimal.ZERO) <= 0);

        // Call Persistence Layer (Layer 3)
        Movie savedMovie = movieRepository.save(movie);
        log.info("Movie created with ID: {}", savedMovie.getId());

        return savedMovie;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Movie> getAllMovies() {
        log.info("Fetching all movies");
        return movieRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Movie getMovieById(Long id) {
        log.info("Fetching movie by ID: {}", id);
        return movieRepository.findById(id)
                .orElseThrow(() -> new MovieNotFoundException(id));
    }

    @Override
    @Transactional(readOnly = true)
    public Movie getMovieBySlug(String slug) {
        log.info("Fetching movie by slug: {}", slug);
        return movieRepository.findBySlug(slug)
                .orElseThrow(() -> new MovieNotFoundException(slug));
    }

    @Override
    public Movie updateMovie(Long id, MovieDTO dto) {
        log.info("Updating movie ID: {}", id);

        // Business Rule: Movie must exist
        Movie existingMovie = getMovieById(id);

        // Business Rule: If slug is changed, it must be unique
        if (!existingMovie.getSlug().equals(dto.getSlug())) {
            if (movieRepository.existsBySlug(dto.getSlug())) {
                throw new DuplicateSlugException(dto.getSlug());
            }
        }

        // Transform DTO to Entity (update existing)
        Movie updatedMovie = mapDtoToEntity(dto, existingMovie);
        updatedMovie.setUpdatedAt(LocalDateTime.now());

        // Business Rule: Update isFree based on price
        updatedMovie.setIsFree(updatedMovie.getPrice() == null || 
                               updatedMovie.getPrice().compareTo(BigDecimal.ZERO) <= 0);

        // Call Persistence Layer (Layer 3)
        Movie savedMovie = movieRepository.save(updatedMovie);
        log.info("Movie updated: {}", savedMovie.getId());

        return savedMovie;
    }

    @Override
    public void deleteMovie(Long id) {
        log.info("Deleting movie ID: {}", id);

        // Business Rule: Movie must exist before deletion
        if (!movieRepository.existsById(id)) {
            throw new MovieNotFoundException(id);
        }

        // Call Persistence Layer (Layer 3)
        movieRepository.deleteById(id);
        log.info("Movie deleted: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Movie> searchMovies(String keyword) {
        log.info("Searching movies with keyword: {}", keyword);

        // Business Rule: Keyword must not be empty
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllMovies();
        }

        return movieRepository.searchByKeyword(keyword.trim());
    }

    @Override
    @Transactional(readOnly = true)
    public List<Movie> getMoviesByType(String type) {
        log.info("Fetching movies by type: {}", type);
        return movieRepository.findByType(type);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Movie> getTopTrending() {
        log.info("Fetching top trending movies");
        return movieRepository.findTop10ByOrderByViewDesc();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Movie> getNewReleases() {
        log.info("Fetching new releases");
        int currentYear = LocalDateTime.now().getYear();
        return movieRepository.findNewReleases(currentYear - 2);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Movie> getFreeMovies() {
        log.info("Fetching free movies");
        return movieRepository.findByIsFreeTrue();
    }

    @Override
    public void incrementViewCount(Long id) {
        log.info("Incrementing view count for movie ID: {}", id);
        Movie movie = getMovieById(id);
        movie.setView(movie.getView() + 1);
        movieRepository.save(movie);
    }

    /**
     * Helper method to map DTO to Entity.
     */
    private Movie mapDtoToEntity(MovieDTO dto, Movie movie) {
        movie.setName(dto.getName());
        movie.setOriginName(dto.getOriginName());
        movie.setSlug(dto.getSlug());
        movie.setContent(dto.getContent());
        movie.setPosterUrl(dto.getPosterUrl());
        movie.setThumbUrl(dto.getThumbUrl());
        movie.setTrailerUrl(dto.getTrailerUrl());
        movie.setType(dto.getType());
        movie.setStatus(dto.getStatus());
        movie.setQuality(dto.getQuality());
        movie.setLang(dto.getLang());
        movie.setYear(dto.getYear());
        movie.setTime(dto.getTime());
        movie.setEpisodeCurrent(dto.getEpisodeCurrent());
        movie.setEpisodeTotal(dto.getEpisodeTotal());
        movie.setPrice(dto.getPrice() != null ? dto.getPrice() : BigDecimal.ZERO);
        movie.setTmdbRating(dto.getTmdbRating());
        movie.setImdbRating(dto.getImdbRating());

        if (dto.getView() != null) {
            movie.setView(dto.getView());
        }

        return movie;
    }
}

