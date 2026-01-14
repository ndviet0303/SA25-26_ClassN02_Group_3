package com.nozie.common.dto;

import lombok.*;
import java.util.List;

/**
 * Pagination Response wrapper.
 * Used for paginated list responses.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PageResponse<T> {

    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean first;
    private boolean last;
}
