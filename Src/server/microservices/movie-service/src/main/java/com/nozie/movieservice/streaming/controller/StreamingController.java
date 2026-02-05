package com.nozie.movieservice.streaming.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.movieservice.common.dto.EpisodesResponse;
import com.nozie.movieservice.common.dto.PlayUrlResponse;
import com.nozie.movieservice.streaming.service.StreamingService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Streaming API - Phát video, episodes, tăng view.
 */
@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StreamingController {

    private static final Logger log = LoggerFactory.getLogger(StreamingController.class);
    private final StreamingService streamingService;
    private final com.nozie.movieservice.catalog.service.CatalogService catalogService;
    private final com.nozie.movieservice.streaming.service.AccessControlService accessControlService;

    /** POST /api/movies/{id}/view - Tăng lượt xem */
    @PostMapping("/{id}/view")
    public ResponseEntity<ApiResponse<Void>> incrementViewById(@PathVariable String id) {
        log.info("POST /api/movies/{}/view", id);
        streamingService.incrementViewCount(id);
        return ResponseEntity.ok(ApiResponse.success("View count incremented", null));
    }

    /** POST /api/movies/slug/{slug}/view - Tăng lượt xem theo slug */
    @PostMapping("/slug/{slug}/view")
    public ResponseEntity<ApiResponse<Void>> incrementViewBySlug(@PathVariable String slug) {
        log.info("POST /api/movies/slug/{}/view", slug);
        streamingService.incrementViewCountBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success("View count incremented", null));
    }

    /** GET /api/movies/{id}/play - URL phát mặc định */
    @GetMapping("/{id}/play")
    public ResponseEntity<ApiResponse<PlayUrlResponse>> getPlayUrl(
            @PathVariable String id,
            @RequestParam(required = false, defaultValue = "0") int server,
            @RequestParam(required = false, defaultValue = "0") int episode,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        log.info("GET /api/movies/{}/play?server={}&episode={}&user={}", id, server, episode, userId);

        com.nozie.movieservice.common.model.Movie movie = catalogService.getMovieById(id);
        if (!accessControlService.canWatch(movie, userId)) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Premium subscription required to watch this movie"));
        }

        PlayUrlResponse play = streamingService.getPlayUrl(id, server, episode);
        return ResponseEntity.ok(ApiResponse.success(play));
    }

    /** GET /api/movies/slug/{slug}/play - URL phát theo slug */
    @GetMapping("/slug/{slug}/play")
    public ResponseEntity<ApiResponse<PlayUrlResponse>> getPlayUrlBySlug(
            @PathVariable String slug,
            @RequestParam(required = false, defaultValue = "0") int server,
            @RequestParam(required = false, defaultValue = "0") int episode,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        log.info("GET /api/movies/slug/{}/play?server={}&episode={}&user={}", slug, server, episode, userId);

        com.nozie.movieservice.common.model.Movie movie = catalogService.getMovieBySlug(slug);
        if (!accessControlService.canWatch(movie, userId)) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Premium subscription required to watch this movie"));
        }

        PlayUrlResponse play = streamingService.getPlayUrlBySlug(slug, server, episode);
        return ResponseEntity.ok(ApiResponse.success(play));
    }

    /** GET /api/movies/{id}/episodes - Danh sách episodes */
    @GetMapping("/{id}/episodes")
    public ResponseEntity<ApiResponse<EpisodesResponse>> getEpisodes(
            @PathVariable String id,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        log.info("GET /api/movies/{}/episodes&user={}", id, userId);

        com.nozie.movieservice.common.model.Movie movie = catalogService.getMovieById(id);
        // Even for episodes metadata, we might want to check permission if we want to
        // hide urls completely
        if (!accessControlService.canWatch(movie, userId)) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Premium subscription required to access episodes"));
        }

        EpisodesResponse episodes = streamingService.getEpisodes(id);
        return ResponseEntity.ok(ApiResponse.success(episodes));
    }

    /** GET /api/movies/slug/{slug}/episodes - Danh sách episodes */
    @GetMapping("/slug/{slug}/episodes")
    public ResponseEntity<ApiResponse<EpisodesResponse>> getEpisodesBySlug(
            @PathVariable String slug,
            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        log.info("GET /api/movies/slug/{}/episodes&user={}", slug, userId);

        com.nozie.movieservice.common.model.Movie movie = catalogService.getMovieBySlug(slug);
        if (!accessControlService.canWatch(movie, userId)) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Premium subscription required to access episodes"));
        }

        EpisodesResponse episodes = streamingService.getEpisodesBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(episodes));
    }
}
