package com.nozie.movieservice.common.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Quốc gia - sync từ OPhim GET /quoc-gia.
 */
@Document(collection = "countries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Country {

    @Id
    private String id;

    private String name;

    @Indexed(unique = true)
    private String slug;
}
