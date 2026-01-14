package com.nozie.movieservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.common.exception.ResourceNotFoundException;
import com.nozie.movieservice.dto.MovieRequest;
import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.repository.MovieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * Layer 2: Business Logic Layer - Movie Service
 */
@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class MovieService {

    private final MovieRepository movieRepository;

    public Movie createMovie(MovieRequest request) {
        log.info("Creating movie: {}", request.getName());

        if (movieRepository.existsBySlug(request.getSlug())) {
            throw new BadRequestException("Movie with slug '" + request.getSlug() + "' already exists");
        }

        Movie movie = mapToEntity(request, new Movie());
        movie.setIsFree(movie.getPrice() == null || movie.getPrice().compareTo(BigDecimal.ZERO) <= 0);

        return movieRepository.save(movie);
    }

    @Transactional(readOnly = true)
    public List<Movie> getAllMovies() {
        return movieRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Movie getMovieById(String id) {
        return movieRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", id));
    }

    @Transactional(readOnly = true)
    public Movie getMovieBySlug(String slug) {
        return movieRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "slug", slug));
    }

    public Movie updateMovie(String id, MovieRequest request) {
        Movie existingMovie = getMovieById(id);

        if (!existingMovie.getSlug().equals(request.getSlug()) &&
                movieRepository.existsBySlug(request.getSlug())) {
            throw new BadRequestException("Movie with slug '" + request.getSlug() + "' already exists");
        }

        Movie updatedMovie = mapToEntity(request, existingMovie);
        updatedMovie.setIsFree(updatedMovie.getPrice() == null ||
                updatedMovie.getPrice().compareTo(BigDecimal.ZERO) <= 0);

        return movieRepository.save(updatedMovie);
    }

    public void deleteMovie(String id) {
        if (!movieRepository.existsById(id)) {
            throw new ResourceNotFoundException("Movie", "id", id);
        }
        movieRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<Movie> searchMovies(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllMovies();
        }
        return movieRepository.findByNameContainingIgnoreCaseOrOriginNameContainingIgnoreCase(keyword.trim(),
                keyword.trim());
    }

    @Transactional(readOnly = true)
    public List<Movie> getMoviesByType(String type) {
        return movieRepository.findByType(type);
    }

    @Transactional(readOnly = true)
    public List<Movie> getTrendingMovies() {
        return movieRepository.findTop10ByOrderByViewDesc();
    }

    @Transactional(readOnly = true)
    public List<Movie> getFreeMovies() {
        return movieRepository.findByIsFreeTrue();
    }

    public void incrementViewCount(String id) {
        Movie movie = getMovieById(id);
        movie.setView(movie.getView() + 1);
        movieRepository.save(movie);
    }

    private Movie mapToEntity(MovieRequest request, Movie movie) {
        movie.setName(request.getName());
        movie.setOriginName(request.getOriginName());
        movie.setSlug(request.getSlug());
        movie.setContent(request.getContent());
        movie.setPosterUrl(request.getPosterUrl());
        movie.setThumbUrl(request.getThumbUrl());
        movie.setTrailerUrl(request.getTrailerUrl());
        movie.setType(request.getType());
        movie.setStatus(request.getStatus());
        movie.setQuality(request.getQuality());
        movie.setLang(request.getLang());
        movie.setYear(request.getYear());
        movie.setTime(request.getTime());
        movie.setEpisodeCurrent(request.getEpisodeCurrent());
        movie.setEpisodeTotal(request.getEpisodeTotal());
        movie.setPrice(request.getPrice() != null ? request.getPrice() : BigDecimal.ZERO);
        movie.setTmdbRating(request.getTmdbRating());
        movie.setImdbRating(request.getImdbRating());
        return movie;
    }
}
