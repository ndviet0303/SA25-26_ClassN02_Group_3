package com.nozie.movieservice.common.dto;

import lombok.Builder;
import lombok.Data;

/**
 * Thông tin 1 tập phim để phát (dùng trong EpisodesResponse).
 */
@Data
@Builder
public class EpisodePlayInfo {

    private String name;
    private String slug;
    private String m3u8Url;
    private String embedUrl;
}
