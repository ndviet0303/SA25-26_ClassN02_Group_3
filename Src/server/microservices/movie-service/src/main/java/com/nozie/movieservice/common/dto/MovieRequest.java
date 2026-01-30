package com.nozie.movieservice.common.dto;

import com.nozie.movieservice.common.model.Movie;
import lombok.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieRequest {

    @NotBlank(message = "Movie name is required")
    private String name;

    private String originName;

    @NotBlank(message = "Slug is required")
    private String slug;

    private String content;
    private String posterUrl;
    private String thumbUrl;
    private String trailerUrl;
    private String type;
    private String status;
    private String quality;
    private String lang;

    @Min(value = 1900)
    @Max(value = 2100)
    private Integer year;

    private String time;
    private String episodeCurrent;
    private String episodeTotal;

    @DecimalMin(value = "0.0")
    private BigDecimal price;

    private Movie.AccessType accessType;

    private Double tmdbRating;
    private Double imdbRating;
}
