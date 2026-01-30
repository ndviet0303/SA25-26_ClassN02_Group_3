package com.nozie.movieservice.common.model;

import lombok.*;

/**
 * Một tập / một link phát (link_embed + link_m3u8).
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServerDataItem {

    private String name;
    private String slug;
    private String filename;
    /** Link embed - nhúng iframe. MongoDB: linkEmbed (từ import) */
    private String linkEmbed;
    /** Link m3u8 - phát HLS. MongoDB: linkM3u8 (từ import) */
    private String linkM3u8;
}
