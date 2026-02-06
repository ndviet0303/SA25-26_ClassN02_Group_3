package com.nozie.movieservice.recommendation.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.movieservice.common.dto.MovieListItemResponse;
import com.nozie.movieservice.recommendation.service.RecommendationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * RecommendationController - API for movie recommendations (UC26/27)
 */
@RestController
@RequestMapping("/api/recommendations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Slf4j
public class RecommendationController {

    private final RecommendationService recommendationService;

    /**
     * GET /api/recommendations/{userId} - Personalized recommendations
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getRecommendations(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "12") int limit) {
        log.info("GET /api/recommendations/{} - limit={}", userId, limit);
        List<MovieListItemResponse> recommendations = recommendationService.getRecommendationsForUser(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(recommendations));
    }

    /**
     * GET /api/recommendations/similar/{movieId} - Similar movies
     */
    @GetMapping("/similar/{movieId}")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getSimilarMovies(
            @PathVariable String movieId,
            @RequestParam(defaultValue = "12") int limit) {
        log.info("GET /api/recommendations/similar/{} - limit={}", movieId, limit);
        List<MovieListItemResponse> similar = recommendationService.getSimilarMovies(movieId, limit);
        return ResponseEntity.ok(ApiResponse.success(similar));
    }

    /**
     * GET /api/recommendations/series/{movieId} - Series/Franchise movies
     */
    @GetMapping("/series/{movieId}")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getSeriesMovies(
            @PathVariable String movieId,
            @RequestParam(defaultValue = "12") int limit) {
        log.info("GET /api/recommendations/series/{} - limit={}", movieId, limit);
        List<MovieListItemResponse> series = recommendationService.getSeriesMovies(movieId, limit);
        return ResponseEntity.ok(ApiResponse.success(series));
    }

    /**
     * GET /api/recommendations/trending - Trending movies (public fallback)
     */
    @GetMapping("/trending")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getTrending(
            @RequestParam(defaultValue = "12") int limit) {
        log.info("GET /api/recommendations/trending - limit={}", limit);
        List<MovieListItemResponse> trending = recommendationService.getTrendingMovies(limit);
        return ResponseEntity.ok(ApiResponse.success(trending));
    }
}
