package com.nozie.movieservice.catalog.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.common.exception.ResourceNotFoundException;
import com.nozie.movieservice.common.dto.MovieListItemResponse;
import com.nozie.movieservice.common.dto.MovieRequest;
import com.nozie.movieservice.common.dto.PageResponse;
import com.nozie.movieservice.common.model.Country;
import com.nozie.movieservice.common.model.Genre;
import com.nozie.movieservice.common.model.Movie;
import com.nozie.movieservice.common.repository.CountryRepository;
import com.nozie.movieservice.common.repository.GenreRepository;
import com.nozie.movieservice.common.repository.MovieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class CatalogService {

    private final MovieRepository movieRepository;
    private final GenreRepository genreRepository;
    private final CountryRepository countryRepository;
    private final MovieMapper movieMapper;

    public Movie createMovie(MovieRequest request) {
        log.info("Creating movie: {}", request.getName());

        if (movieRepository.existsBySlug(request.getSlug())) {
            throw new BadRequestException("Movie with slug '" + request.getSlug() + "' already exists");
        }

        Movie movie = mapToEntity(request, new Movie());

        if (movie.getAccessType() == null) {
            if (movie.getPrice() != null && movie.getPrice().compareTo(BigDecimal.ZERO) > 0) {
                movie.setAccessType(Movie.AccessType.RENTAL);
            } else {
                movie.setAccessType(Movie.AccessType.FREE);
            }
        }

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
        return movieRepository.findByAccessType(Movie.AccessType.FREE);
    }

    @Transactional(readOnly = true)
    public PageResponse<MovieListItemResponse> getMoviesWithFilter(String type, String genreSlug,
                                                                   String countrySlug, Integer year,
                                                                   String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), Math.min(50, Math.max(1, size)),
                Sort.by(Sort.Direction.DESC, "updatedAt").nullsLast());
        Page<Movie> p = movieRepository.findWithFilter(type, genreSlug, countrySlug, year, keyword, pageable);
        List<MovieListItemResponse> items = p.getContent().stream()
                .map(movieMapper::toListItem)
                .collect(Collectors.toList());
        return PageResponse.<MovieListItemResponse>builder()
                .items(items)
                .page(p.getNumber() + 1)
                .size(p.getSize())
                .totalItems(p.getTotalElements())
                .totalPages(p.getTotalPages())
                .build();
    }

    @Transactional(readOnly = true)
    public List<Genre> getAllGenres() {
        return genreRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Country> getAllCountries() {
        return countryRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Integer> getDistinctYears() {
        List<Integer> years = movieRepository.findDistinctYears();
        if (years == null) return List.of();
        return years.stream().filter(y -> y != null).sorted((a, b) -> Integer.compare(b, a)).toList();
    }

    @Transactional(readOnly = true)
    public PageResponse<MovieListItemResponse> getMoviesByGenre(String genreSlug, int page, int size) {
        return getMoviesWithFilter(null, genreSlug, null, null, null, page, size);
    }

    @Transactional(readOnly = true)
    public PageResponse<MovieListItemResponse> getMoviesByCountry(String countrySlug, int page, int size) {
        return getMoviesWithFilter(null, null, countrySlug, null, null, page, size);
    }

    @Transactional(readOnly = true)
    public PageResponse<MovieListItemResponse> getMoviesByYear(int year, int page, int size) {
        return getMoviesWithFilter(null, null, null, year, null, page, size);
    }

    @Transactional(readOnly = true)
    public PageResponse<MovieListItemResponse> getLatestMovies(int page, int size) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), Math.min(50, Math.max(1, size)),
                Sort.by(Sort.Direction.DESC, "_id"));
        Page<Movie> p = movieRepository.findAll(pageable);
        List<MovieListItemResponse> items = p.getContent().stream()
                .map(movieMapper::toListItem)
                .collect(Collectors.toList());
        return PageResponse.<MovieListItemResponse>builder()
                .items(items)
                .page(p.getNumber() + 1)
                .size(p.getSize())
                .totalItems(p.getTotalElements())
                .totalPages(p.getTotalPages())
                .build();
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

        if (request.getAccessType() != null) {
            movie.setAccessType(request.getAccessType());
        }

        return movie;
    }
}
