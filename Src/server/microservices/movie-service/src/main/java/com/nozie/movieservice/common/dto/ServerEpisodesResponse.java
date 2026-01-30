package com.nozie.movieservice.common.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Một server phát (Vietsub #1...) với danh sách tập.
 */
@Data
@Builder
public class ServerEpisodesResponse {

    private String serverName;
    private boolean isAi;
    private List<EpisodePlayInfo> episodes;
}
