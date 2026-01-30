package com.nozie.movieservice.common.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Thể loại phim - sync từ OPhim GET /the-loai.
 */
@Document(collection = "genres")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Genre {

    @Id
    private String id;

    private String name;

    @Indexed(unique = true)
    private String slug;
}
