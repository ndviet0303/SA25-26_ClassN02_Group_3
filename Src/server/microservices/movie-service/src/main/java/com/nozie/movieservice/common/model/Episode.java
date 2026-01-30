package com.nozie.movieservice.common.model;

import lombok.*;

import java.util.List;

/**
 * Một server phát (Vietsub #1, ...) chứa danh sách tập với link_embed + link_m3u8.
 * MongoDB: serverName, isAi, serverData (camelCase từ import).
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Episode {

    private String serverName;
    private Boolean isAi;
    private List<ServerDataItem> serverData;
}
