package com.nozie.movieservice.common.dto;

import lombok.Builder;
import lombok.Data;

/**
 * Response chứa URL phát video (m3u8 hoặc embed).
 */
@Data
@Builder
public class PlayUrlResponse {

    private String movieId;
    private String movieName;
    private String serverName;
    private String episodeName;
    private String episodeSlug;
    /** Link HLS m3u8 - dùng để phát trực tiếp */
    private String m3u8Url;
    /** Link embed - nhúng iframe */
    private String embedUrl;
    /** true nếu dùng custom HLS (R2/CDN), false nếu từ OPhim */
    private boolean customHls;
}
