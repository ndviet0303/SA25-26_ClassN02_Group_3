package com.nozie.movieservice.common.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Danh sách episodes theo server (để chọn tập phát).
 */
@Data
@Builder
public class EpisodesResponse {

    private String movieId;
    private String movieName;
    /** Link HLS custom nếu có (ưu tiên phát) */
    private String customHlsUrl;
    private List<ServerEpisodesResponse> servers;
}
