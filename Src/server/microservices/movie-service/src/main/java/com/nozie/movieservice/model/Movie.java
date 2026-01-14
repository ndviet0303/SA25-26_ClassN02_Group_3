package com.nozie.movieservice.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Movie Document
 */
@Document(collection = "movies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Movie {

    @Id
    private String id;

    @NotBlank(message = "Movie name is required")
    private String name;

    @Field("origin_name")
    private String originName;

    @NotBlank(message = "Slug is required")
    @Indexed(unique = true)
    private String slug;

    private String content;

    @Field("poster_url")
    private String posterUrl;

    @Field("thumb_url")
    private String thumbUrl;

    @Field("trailer_url")
    private String trailerUrl;

    private String type;
    private String status;
    private String quality;
    private String lang;

    @Field("year")
    private Integer year;

    @Builder.Default
    private Long view = 0L;

    private String time;

    @Field("episode_current")
    private String episodeCurrent;

    @Field("episode_total")
    private String episodeTotal;

    @Builder.Default
    private BigDecimal price = BigDecimal.ZERO;

    @Field("is_free")
    @Builder.Default
    private Boolean isFree = true;

    private Double tmdbRating;
    private Double imdbRating;

    @Field("created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Field("updated_at")
    private LocalDateTime updatedAt;

    public void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
