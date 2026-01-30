package com.nozie.movieservice.streaming.service;

import com.nozie.common.exception.ResourceNotFoundException;
import com.nozie.movieservice.common.dto.*;
import com.nozie.movieservice.common.model.*;
import com.nozie.movieservice.common.repository.MovieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class StreamingService {

    private final MovieRepository movieRepository;

    public void incrementViewCount(String id) {
        log.info("Incrementing view count for movie: {}", id);
        Movie movie = movieRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", id));
        movie.setView(movie.getView() != null ? movie.getView() + 1 : 1L);
        movieRepository.save(movie);
    }

    public void incrementViewCountBySlug(String slug) {
        Movie movie = movieRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "slug", slug));
        movie.setView(movie.getView() != null ? movie.getView() + 1 : 1L);
        movieRepository.save(movie);
    }

    /**
     * Lấy URL phát mặc định (ưu tiên custom HLS, sau đó tập đầu tiên).
     */
    public PlayUrlResponse getPlayUrl(String movieId) {
        Movie movie = movieRepository.findById(movieId)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", movieId));
        return buildPlayUrl(movie, 0, 0);
    }

    /**
     * Lấy URL phát theo slug.
     */
    public PlayUrlResponse getPlayUrlBySlug(String slug) {
        Movie movie = movieRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "slug", slug));
        return buildPlayUrl(movie, 0, 0);
    }

    /**
     * Lấy URL phát tập cụ thể: serverIndex (0-based), episodeIndex (0-based).
     */
    public PlayUrlResponse getPlayUrl(String movieId, int serverIndex, int episodeIndex) {
        Movie movie = movieRepository.findById(movieId)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", movieId));
        return buildPlayUrl(movie, serverIndex, episodeIndex);
    }

    public PlayUrlResponse getPlayUrlBySlug(String slug, int serverIndex, int episodeIndex) {
        Movie movie = movieRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "slug", slug));
        return buildPlayUrl(movie, serverIndex, episodeIndex);
    }

    /**
     * Danh sách episodes theo server (để chọn tập phát).
     */
    public EpisodesResponse getEpisodes(String movieId) {
        Movie movie = movieRepository.findById(movieId)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "id", movieId));
        return buildEpisodesResponse(movie);
    }

    public EpisodesResponse getEpisodesBySlug(String slug) {
        Movie movie = movieRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Movie", "slug", slug));
        return buildEpisodesResponse(movie);
    }

    private PlayUrlResponse buildPlayUrl(Movie movie, int serverIndex, int episodeIndex) {
        // Ưu tiên custom HLS khi không chỉ định server/episode cụ thể
        if (serverIndex == 0 && episodeIndex == 0 && movie.getCustomHlsUrl() != null && !movie.getCustomHlsUrl().isBlank()) {
            return PlayUrlResponse.builder()
                    .movieId(movie.getId())
                    .movieName(movie.getName())
                    .serverName("Custom")
                    .episodeName("Full")
                    .episodeSlug("full")
                    .m3u8Url(movie.getCustomHlsUrl())
                    .embedUrl(null)
                    .customHls(true)
                    .build();
        }

        List<Episode> episodes = movie.getEpisodes();
        if (episodes == null || episodes.isEmpty()) {
            return PlayUrlResponse.builder()
                    .movieId(movie.getId())
                    .movieName(movie.getName())
                    .serverName(null)
                    .episodeName(null)
                    .episodeSlug(null)
                    .m3u8Url(null)
                    .embedUrl(null)
                    .customHls(false)
                    .build();
        }

        if (serverIndex < 0 || serverIndex >= episodes.size()) {
            serverIndex = 0;
        }

        Episode ep = episodes.get(serverIndex);
        List<ServerDataItem> serverData = ep.getServerData();
        if (serverData == null || serverData.isEmpty()) {
            return PlayUrlResponse.builder()
                    .movieId(movie.getId())
                    .movieName(movie.getName())
                    .serverName(ep.getServerName())
                    .episodeName(null)
                    .episodeSlug(null)
                    .m3u8Url(null)
                    .embedUrl(null)
                    .customHls(false)
                    .build();
        }

        if (episodeIndex < 0 || episodeIndex >= serverData.size()) {
            episodeIndex = 0;
        }

        ServerDataItem item = serverData.get(episodeIndex);
        return PlayUrlResponse.builder()
                .movieId(movie.getId())
                .movieName(movie.getName())
                .serverName(ep.getServerName())
                .episodeName(item.getName())
                .episodeSlug(item.getSlug())
                .m3u8Url(item.getLinkM3u8())
                .embedUrl(item.getLinkEmbed())
                .customHls(false)
                .build();
    }

    private EpisodesResponse buildEpisodesResponse(Movie movie) {
        List<ServerEpisodesResponse> servers = new ArrayList<>();

        if (movie.getEpisodes() != null) {
            for (Episode ep : movie.getEpisodes()) {
                List<EpisodePlayInfo> episodeInfos = new ArrayList<>();
                if (ep.getServerData() != null) {
                    for (ServerDataItem sd : ep.getServerData()) {
                        episodeInfos.add(EpisodePlayInfo.builder()
                                .name(sd.getName())
                                .slug(sd.getSlug())
                                .m3u8Url(sd.getLinkM3u8())
                                .embedUrl(sd.getLinkEmbed())
                                .build());
                    }
                }
                servers.add(ServerEpisodesResponse.builder()
                        .serverName(ep.getServerName())
                        .isAi(ep.getIsAi() != null && ep.getIsAi())
                        .episodes(episodeInfos)
                        .build());
            }
        }

        return EpisodesResponse.builder()
                .movieId(movie.getId())
                .movieName(movie.getName())
                .customHlsUrl(movie.getCustomHlsUrl())
                .servers(servers)
                .build();
    }
}
