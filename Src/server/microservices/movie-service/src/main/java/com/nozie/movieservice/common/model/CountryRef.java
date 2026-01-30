package com.nozie.movieservice.common.model;

import lombok.*;

/**
 * Quốc gia (embedded trong Movie).
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CountryRef {

    private String id;
    private String name;
    private String slug;
}
