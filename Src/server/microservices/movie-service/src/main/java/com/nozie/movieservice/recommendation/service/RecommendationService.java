package com.nozie.movieservice.recommendation.service;

import com.nozie.movieservice.catalog.service.MovieMapper;
import com.nozie.movieservice.common.dto.MovieListItemResponse;
import com.nozie.movieservice.common.model.CategoryRef;
import com.nozie.movieservice.common.model.Movie;
import com.nozie.movieservice.common.repository.MovieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

/**
 * RecommendationService - Generate movie recommendations based on viewing
 * history
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class RecommendationService {

    private final MovieRepository movieRepository;
    private final MovieMapper movieMapper;
    private final RestTemplate restTemplate;

    @Value("${services.customer-service.url:http://customer-service:8082}")
    private String customerServiceUrl;

    /**
     * Get personalized recommendations for a user
     */
    public List<MovieListItemResponse> getRecommendationsForUser(Long userId, int limit) {
        log.info("Generating recommendations for user: {}", userId);

        try {
            // 1. Get viewing history from customer-service
            List<String> watchedMovieIds = getWatchedMovieIds(userId);

            if (watchedMovieIds.isEmpty()) {
                log.info("No viewing history for user {}, returning trending", userId);
                return getTrendingMovies(limit);
            }

            // 2. Analyze genres from watched movies
            List<String> topGenreSlugs = getTopGenresFromMovies(watchedMovieIds, 3);

            if (topGenreSlugs.isEmpty()) {
                return getTrendingMovies(limit);
            }

            // 3. Find movies in those genres, excluding already watched
            List<Movie> recommendations = findMoviesByGenresExcluding(topGenreSlugs, watchedMovieIds, limit);

            log.info("Found {} recommendations for user {}", recommendations.size(), userId);
            return recommendations.stream()
                    .map(movieMapper::toListItem)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("Error generating recommendations: {}", e.getMessage());
            return getTrendingMovies(limit);
        }
    }

    /**
     * Get movies similar to a specific movie (same genres)
     */
    public List<MovieListItemResponse> getSimilarMovies(String movieId, int limit) {
        log.info("Finding similar movies to: {}", movieId);

        return movieRepository.findById(movieId)
                .map(movie -> {
                    List<String> genreSlugs = movie.getCategory() != null
                            ? movie.getCategory().stream()
                                    .map(CategoryRef::getSlug)
                                    .filter(Objects::nonNull)
                                    .collect(Collectors.toList())
                            : List.of();

                    if (genreSlugs.isEmpty()) {
                        return getTrendingMovies(limit);
                    }

                    List<Movie> similar = findMoviesByGenresExcluding(genreSlugs, List.of(movieId), limit);
                    return similar.stream()
                            .map(movieMapper::toListItem)
                            .collect(Collectors.toList());
                })
                .orElse(getTrendingMovies(limit));
    }

    /**
     * Get movies in the same series/franchise (same slug prefix)
     */
    public List<MovieListItemResponse> getSeriesMovies(String movieId, int limit) {
        log.info("Finding franchise/series movies for: {}", movieId);

        return movieRepository.findById(movieId)
                .map(movie -> {
                    String slug = movie.getSlug();
                    if (slug == null || !slug.contains("-")) {
                        return List.<MovieListItemResponse>of();
                    }
                    String prefix = slug.split("-")[0];
                    List<Movie> series = movieRepository.findAll().stream()
                            .filter(m -> !m.getId().equals(movieId))
                            .filter(m -> m.getSlug() != null && m.getSlug().startsWith(prefix + "-"))
                            .limit(limit)
                            .collect(Collectors.toList());
                    return series.stream()
                            .map(movieMapper::toListItem)
                            .collect(Collectors.toList());
                })
                .orElse(List.of());
    }

    /**
     * Get trending movies (fallback)
     */
    public List<MovieListItemResponse> getTrendingMovies(int limit) {
        return movieRepository.findTop10ByOrderByViewDesc().stream()
                .limit(limit)
                .map(movieMapper::toListItem)
                .collect(Collectors.toList());
    }

    /**
     * Fetch watched movie IDs from customer-service
     */
    private List<String> getWatchedMovieIds(Long userId) {
        try {
            String url = customerServiceUrl + "/api/customers/" + userId + "/history?limit=50";
            log.debug("Fetching viewing history from: {}", url);

            var response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });

            if (response.getBody() != null && response.getBody().get("data") != null) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> historyList = (List<Map<String, Object>>) response.getBody().get("data");
                return historyList.stream()
                        .map(h -> (String) h.get("movieId"))
                        .filter(Objects::nonNull)
                        .distinct()
                        .collect(Collectors.toList());
            }
            return List.of();
        } catch (Exception e) {
            log.warn("Failed to fetch viewing history: {}", e.getMessage());
            return List.of();
        }
    }

    /**
     * Analyze watched movies to find top genres
     */
    private List<String> getTopGenresFromMovies(List<String> movieIds, int topN) {
        Map<String, Long> genreCount = new HashMap<>();

        for (String movieId : movieIds) {
            movieRepository.findById(movieId).ifPresent(movie -> {
                if (movie.getCategory() != null) {
                    for (CategoryRef cat : movie.getCategory()) {
                        if (cat.getSlug() != null) {
                            genreCount.merge(cat.getSlug(), 1L, Long::sum);
                        }
                    }
                }
            });
        }

        return genreCount.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(topN)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    /**
     * Find movies by genre slugs, excluding specific movie IDs
     */
    private List<Movie> findMoviesByGenresExcluding(List<String> genreSlugs, List<String> excludeIds, int limit) {
        // Query all movies and filter in memory (simple approach)
        // For production, use MongoDB aggregation pipeline
        return movieRepository.findAll().stream()
                .filter(movie -> !excludeIds.contains(movie.getId()))
                .filter(movie -> movie.getCategory() != null && movie.getCategory().stream()
                        .anyMatch(cat -> genreSlugs.contains(cat.getSlug())))
                .sorted((a, b) -> {
                    // Sort by view count descending
                    Long viewA = a.getView() != null ? a.getView() : 0L;
                    Long viewB = b.getView() != null ? b.getView() : 0L;
                    return viewB.compareTo(viewA);
                })
                .limit(limit)
                .collect(Collectors.toList());
    }
}
