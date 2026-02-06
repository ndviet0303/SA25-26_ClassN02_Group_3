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
 * history and user interests
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
            // 1. Get customer ID from user ID
            Long customerId = getCustomerId(userId);
            if (customerId == null) {
                log.warn("Customer not found for user {}, returning trending", userId);
                return getTrendingMovies(limit);
            }

            // 2. Get viewing history
            List<String> watchedMovieIds = getWatchedMovieIds(customerId);

            // 3. Get explicit interests
            List<String> interestGenreSlugs = getInterestGenreSlugs(customerId);
            log.info("User {} explicit interests: {}", userId, interestGenreSlugs);

            // 4. Analyze genres from watched movies
            List<String> topGenreSlugsFromHistory = getTopGenresFromMovies(watchedMovieIds, 3);

            // 5. Merge genres (interests + history)
            Set<String> mergedGenres = new HashSet<>(interestGenreSlugs);
            mergedGenres.addAll(topGenreSlugsFromHistory);

            if (mergedGenres.isEmpty()) {
                log.info("No history or interests for user {}, returning trending", userId);
                return getTrendingMovies(limit);
            }

            // 6. Find movies in those genres, excluding already watched
            List<Movie> recommendations = findMoviesByGenresExcluding(new ArrayList<>(mergedGenres), watchedMovieIds,
                    limit);

            log.info("Found {} recommendations for user {}", recommendations.size(), userId);
            return recommendations.stream()
                    .map(movieMapper::toListItem)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("Error generating recommendations for user {}: {}", userId, e.getMessage());
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
     * Get Customer ID from User ID by calling customer-service
     */
    private Long getCustomerId(Long userId) {
        try {
            String url = customerServiceUrl + "/api/customers/user/" + userId;
            var response = restTemplate.exchange(
                    url, HttpMethod.GET, null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });

            if (response.getBody() != null && response.getBody().get("data") != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> customer = (Map<String, Object>) response.getBody().get("data");
                Object id = customer.get("id");
                if (id instanceof Number) {
                    return ((Number) id).longValue();
                }
            }
            return null;
        } catch (Exception e) {
            log.warn("Failed to fetch customer for user {}: {}", userId, e.getMessage());
            return null;
        }
    }

    /**
     * Fetch watched movie IDs from customer-service
     */
    private List<String> getWatchedMovieIds(Long customerId) {
        try {
            String url = customerServiceUrl + "/api/customers/" + customerId + "/history?limit=50";
            var response = restTemplate.exchange(
                    url, HttpMethod.GET, null,
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
            log.warn("Failed to fetch viewing history for customer {}: {}", customerId, e.getMessage());
            return List.of();
        }
    }

    /**
     * Fetch explicit interest genre slugs from customer-service
     */
    private List<String> getInterestGenreSlugs(Long customerId) {
        try {
            String url = customerServiceUrl + "/api/customers/" + customerId + "/interests";
            var response = restTemplate.exchange(
                    url, HttpMethod.GET, null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });

            if (response.getBody() != null && response.getBody().get("data") != null) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> interests = (List<Map<String, Object>>) response.getBody().get("data");
                return interests.stream()
                        .map(i -> (String) i.get("genreSlug"))
                        .filter(Objects::nonNull)
                        .collect(Collectors.toList());
            }
            return List.of();
        } catch (Exception e) {
            log.warn("Failed to fetch interests for customer {}: {}", customerId, e.getMessage());
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
        return movieRepository.findAll().stream()
                .filter(movie -> !excludeIds.contains(movie.getId()))
                .filter(movie -> movie.getCategory() != null && movie.getCategory().stream()
                        .anyMatch(cat -> genreSlugs.contains(cat.getSlug())))
                .sorted((a, b) -> {
                    Long viewA = a.getView() != null ? a.getView() : 0L;
                    Long viewB = b.getView() != null ? b.getView() : 0L;
                    return viewB.compareTo(viewA);
                })
                .limit(limit)
                .collect(Collectors.toList());
    }
}
