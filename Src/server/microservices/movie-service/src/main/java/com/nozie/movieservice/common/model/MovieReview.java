package com.nozie.movieservice.common.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

/**
 * UC13: Rate & Review Movie – User review/rating for a movie.
 */
@Document(collection = "movie_reviews")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieReview {

    @Id
    private String id;

    @Indexed
    private String movieId;

    private Long userId;

    private Integer score; // 1-10

    private String comment;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
