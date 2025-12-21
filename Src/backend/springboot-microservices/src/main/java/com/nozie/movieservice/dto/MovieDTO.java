package com.nozie.movieservice.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

/**
 * Data Transfer Object for Movie.
 * Used to transfer data between Presentation and Business Logic layers.
 * Separates API contract from internal entity structure.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieDTO {

    private Long id;

    @NotBlank(message = "Movie name is required")
    @Size(min = 1, max = 255, message = "Name must be between 1 and 255 characters")
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

    @Min(value = 1900, message = "Year must be after 1900")
    @Max(value = 2100, message = "Year must be before 2100")
    private Integer year;

    private Long view;

    private String time;

    private String episodeCurrent;

    private String episodeTotal;

    @DecimalMin(value = "0.0", message = "Price cannot be negative")
    private BigDecimal price;

    private Boolean isFree;

    private Double tmdbRating;

    private Double imdbRating;
}

