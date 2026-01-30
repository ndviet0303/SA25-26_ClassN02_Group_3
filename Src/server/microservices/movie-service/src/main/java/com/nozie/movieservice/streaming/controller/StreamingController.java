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

    /** GET /api/movies/{id}/play - URL phát mặc định (ưu tiên custom HLS, sau đó tập đầu) */
    @GetMapping("/{id}/play")
    public ResponseEntity<ApiResponse<PlayUrlResponse>> getPlayUrl(
            @PathVariable String id,
            @RequestParam(required = false, defaultValue = "0") int server,
            @RequestParam(required = false, defaultValue = "0") int episode) {
        log.info("GET /api/movies/{}/play?server={}&episode={}", id, server, episode);
        PlayUrlResponse play = streamingService.getPlayUrl(id, server, episode);
        return ResponseEntity.ok(ApiResponse.success(play));
    }

    /** GET /api/movies/slug/{slug}/play - URL phát theo slug */
    @GetMapping("/slug/{slug}/play")
    public ResponseEntity<ApiResponse<PlayUrlResponse>> getPlayUrlBySlug(
            @PathVariable String slug,
            @RequestParam(required = false, defaultValue = "0") int server,
            @RequestParam(required = false, defaultValue = "0") int episode) {
        log.info("GET /api/movies/slug/{}/play?server={}&episode={}", slug, server, episode);
        PlayUrlResponse play = streamingService.getPlayUrlBySlug(slug, server, episode);
        return ResponseEntity.ok(ApiResponse.success(play));
    }

    /** GET /api/movies/{id}/episodes - Danh sách episodes theo server */
    @GetMapping("/{id}/episodes")
    public ResponseEntity<ApiResponse<EpisodesResponse>> getEpisodes(@PathVariable String id) {
        log.info("GET /api/movies/{}/episodes", id);
        EpisodesResponse episodes = streamingService.getEpisodes(id);
        return ResponseEntity.ok(ApiResponse.success(episodes));
    }

    /** GET /api/movies/slug/{slug}/episodes - Danh sách episodes theo slug */
    @GetMapping("/slug/{slug}/episodes")
    public ResponseEntity<ApiResponse<EpisodesResponse>> getEpisodesBySlug(@PathVariable String slug) {
        log.info("GET /api/movies/slug/{}/episodes", slug);
        EpisodesResponse episodes = streamingService.getEpisodesBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(episodes));
    }
}
