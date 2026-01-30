package com.nozie.movieservice.common.model;

import lombok.*;

/**
 * Thể loại (embedded trong Movie).
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryRef {

    private String id;
    private String name;
    private String slug;
}
