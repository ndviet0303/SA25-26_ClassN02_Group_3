package com.nozie.movieservice.catalog.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.movieservice.common.dto.*;
import com.nozie.movieservice.common.model.Country;
import com.nozie.movieservice.common.model.Genre;
import com.nozie.movieservice.common.model.Movie;
import com.nozie.movieservice.common.model.MovieReview;
import com.nozie.movieservice.catalog.service.CatalogService;
import com.nozie.movieservice.catalog.service.MovieMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Catalog API - Danh sách phim, tìm kiếm, filter, CRUD.
 */
@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CatalogController {

    private static final Logger log = LoggerFactory.getLogger(CatalogController.class);
    private final CatalogService catalogService;
    private final MovieMapper movieMapper;

    /** GET /api/movies - Danh sách có filter + pagination */
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> getMovies(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String genre,
            @RequestParam(required = false) String country,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false, name = "q") String keyword) {
        log.info("GET /api/movies - page={}, size={}, type={}, genre={}, country={}, year={}, q={}",
                page, size, type, genre, country, year, keyword);
        PageResponse<MovieListItemResponse> result = catalogService.getMoviesWithFilter(
                type, genre, country, year, keyword, page, size);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /** GET /api/movies/search - Tìm kiếm theo từ khóa */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> searchMovies(
            @RequestParam(name = "q", required = false) String keyword,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size) {
        log.info("GET /api/movies/search - q='{}', page={}, size={}", keyword, page, size);

        if (keyword == null || keyword.trim().isEmpty()) {
            log.warn("Search keyword 'q' is missing or empty");
            // Trả về trang trống thay vì lỗi server
            return ResponseEntity.ok(ApiResponse.success(
                    new PageResponse<>(List.of(), page, size, 0L, 0)));
        }

        PageResponse<MovieListItemResponse> result = catalogService.getMoviesWithFilter(
                null, null, null, null, keyword, page, size);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /** GET /api/movies/latest - Phim mới cập nhật */
    @GetMapping("/latest")
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> getLatestMovies(
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size) {
        log.info("GET /api/movies/latest - page={}, size={}", page, size);
        return ResponseEntity.ok(ApiResponse.success(catalogService.getLatestMovies(page, size)));
    }

    /** GET /api/movies/trending - Top phim xem nhiều */
    @GetMapping("/trending")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getTrendingMovies() {
        log.info("GET /api/movies/trending");
        List<Movie> movies = catalogService.getTrendingMovies();
        List<MovieListItemResponse> items = movies.stream().map(movieMapper::toListItem).toList();
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /** GET /api/movies/free - Phim miễn phí */
    @GetMapping("/free")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getFreeMovies() {
        log.info("GET /api/movies/free");
        List<Movie> movies = catalogService.getFreeMovies();
        List<MovieListItemResponse> items = movies.stream().map(movieMapper::toListItem).toList();
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /** GET /api/movies/type/{type} - Phim theo loại (single/series/hoathinh) */
    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> getMoviesByType(
            @PathVariable String type,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size) {
        log.info("GET /api/movies/type/{}", type);
        PageResponse<MovieListItemResponse> result = catalogService.getMoviesWithFilter(
                type, null, null, null, null, page, size);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /** GET /api/movies/genre/{slug} - Phim theo thể loại */
    @GetMapping("/genre/{slug}")
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> getMoviesByGenre(
            @PathVariable String slug,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size) {
        log.info("GET /api/movies/genre/{}", slug);
        return ResponseEntity.ok(ApiResponse.success(catalogService.getMoviesByGenre(slug, page, size)));
    }

    /** GET /api/movies/country/{slug} - Phim theo quốc gia */
    @GetMapping("/country/{slug}")
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> getMoviesByCountry(
            @PathVariable String slug,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size) {
        log.info("GET /api/movies/country/{}", slug);
        return ResponseEntity.ok(ApiResponse.success(catalogService.getMoviesByCountry(slug, page, size)));
    }

    /** GET /api/movies/year/{year} - Phim theo năm */
    @GetMapping("/year/{year}")
    public ResponseEntity<ApiResponse<PageResponse<MovieListItemResponse>>> getMoviesByYear(
            @PathVariable int year,
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "24") int size) {
        log.info("GET /api/movies/year/{}", year);
        return ResponseEntity.ok(ApiResponse.success(catalogService.getMoviesByYear(year, page, size)));
    }

    /** GET /api/movies/slug/{slug} - Chi tiết phim theo slug */
    @GetMapping("/slug/{slug}")
    public ResponseEntity<ApiResponse<MovieResponse>> getMovieBySlug(@PathVariable String slug) {
        log.info("GET /api/movies/slug/{}", slug);
        Movie movie = catalogService.getMovieBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(movieMapper.toResponse(movie)));
    }

    /** GET /api/movies/{id} - Chi tiết phim theo ID */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<MovieResponse>> getMovieById(@PathVariable String id) {
        log.info("GET /api/movies/{}", id);
        Movie movie = catalogService.getMovieById(id);
        return ResponseEntity.ok(ApiResponse.success(movieMapper.toResponse(movie)));
    }

    @GetMapping("/user/{userId}/watchlist")
    public ResponseEntity<ApiResponse<List<MovieListItemResponse>>> getWatchlistByUser(@PathVariable Long userId) {
        log.info("GET /api/movies/user/{}/watchlist", userId);
        List<Movie> movies = catalogService.getWatchlistMovies(userId);
        List<MovieListItemResponse> items = movies.stream().map(movieMapper::toListItem).toList();
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /** POST /api/movies - Tạo phim */
    @PostMapping
    public ResponseEntity<ApiResponse<Movie>> createMovie(@Valid @RequestBody MovieRequest request) {
        log.info("POST /api/movies - Creating: {}", request.getName());
        Movie movie = catalogService.createMovie(request);
        return new ResponseEntity<>(ApiResponse.success("Movie created successfully", movie), HttpStatus.CREATED);
    }

    /** PUT /api/movies/{id} - Cập nhật phim */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Movie>> updateMovie(@PathVariable String id,
            @Valid @RequestBody MovieRequest request) {
        log.info("PUT /api/movies/{}", id);
        Movie movie = catalogService.updateMovie(id, request);
        return ResponseEntity.ok(ApiResponse.success("Movie updated successfully", movie));
    }

    /** DELETE /api/movies/{id} - Xóa phim */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteMovie(@PathVariable String id) {
        log.info("DELETE /api/movies/{}", id);
        catalogService.deleteMovie(id);
        return ResponseEntity.ok(ApiResponse.success("Movie deleted successfully", null));
    }

    /** UC13: POST /api/movies/{id}/rate - Gửi đánh giá & review */
    @PostMapping("/{id}/rate")
    public ResponseEntity<ApiResponse<MovieReview>> rateMovie(
            @PathVariable String id,
            @RequestBody Map<String, Object> body) {
        log.info("POST /api/movies/{}/rate", id);
        Long userId = body.get("userId") != null ? ((Number) body.get("userId")).longValue() : null;
        Integer score = body.get("score") != null ? ((Number) body.get("score")).intValue() : null;
        String comment = body.get("comment") != null ? body.get("comment").toString() : null;
        if (userId == null || score == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("userId and score (1-10) are required"));
        }
        MovieReview review = catalogService.submitRating(id, userId, score, comment);
        return new ResponseEntity<>(ApiResponse.success("Rating submitted", review), HttpStatus.CREATED);
    }

    /** UC13: GET /api/movies/{id}/reviews - Lấy danh sách review */
    @GetMapping("/{id}/reviews")
    public ResponseEntity<ApiResponse<List<MovieReview>>> getMovieReviews(
            @PathVariable String id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.info("GET /api/movies/{}/reviews", id);
        List<MovieReview> reviews = catalogService.getReviews(id, page, size);
        return ResponseEntity.ok(ApiResponse.success(reviews));
    }

    /** GET /api/movies/genres - Lấy danh sách thể loại */
    @GetMapping("/genres")
    public ResponseEntity<ApiResponse<List<Genre>>> getGenres() {
        log.info("GET /api/movies/genres");
        return ResponseEntity.ok(ApiResponse.success(catalogService.getAllGenres()));
    }

    /** GET /api/movies/countries - Lấy danh sách quốc gia */
    @GetMapping("/countries")
    public ResponseEntity<ApiResponse<List<Country>>> getCountries() {
        log.info("GET /api/movies/countries");
        return ResponseEntity.ok(ApiResponse.success(catalogService.getAllCountries()));
    }

    /** GET /api/movies/years - Lấy danh sách năm */
    @GetMapping("/years")
    public ResponseEntity<ApiResponse<List<Integer>>> getYears() {
        log.info("GET /api/movies/years");
        return ResponseEntity.ok(ApiResponse.success(catalogService.getDistinctYears()));
    }
}
