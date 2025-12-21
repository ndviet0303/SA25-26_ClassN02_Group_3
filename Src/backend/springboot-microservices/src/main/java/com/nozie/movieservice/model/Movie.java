package com.nozie.movieservice.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Movie Entity - Core data model.
 * Represents the structure of movie data stored in the database (Layer 4).
 * Used across all layers of the application.
 */
@Entity
@Table(name = "movies")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Movie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Movie name is required")
    @Size(min = 1, max = 255, message = "Name must be between 1 and 255 characters")
    @Column(nullable = false)
    private String name;

    @Column(name = "origin_name")
    private String originName;

    @NotBlank(message = "Slug is required")
    @Column(unique = true, nullable = false)
    private String slug;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(name = "poster_url")
    private String posterUrl;

    @Column(name = "thumb_url")
    private String thumbUrl;

    @Column(name = "trailer_url")
    private String trailerUrl;

    private String type; // movie, series, hoathinh, tvshow

    private String status; // ongoing, completed, upcoming

    private String quality; // HD, FHD, 4K

    private String lang; // Vietsub, Thuyetminh, Engsub

    @Min(value = 1900, message = "Year must be after 1900")
    @Max(value = 2100, message = "Year must be before 2100")
    private Integer year;

    @Min(value = 0, message = "View count cannot be negative")
    @Builder.Default
    private Long view = 0L;

    private String time; // e.g., "120 phút"

    @Column(name = "episode_current")
    private String episodeCurrent;

    @Column(name = "episode_total")
    private String episodeTotal;

    @DecimalMin(value = "0.0", message = "Price cannot be negative")
    @Column(precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal price = BigDecimal.ZERO;

    @Column(name = "is_free")
    @Builder.Default
    private Boolean isFree = true;

    @Column(name = "tmdb_rating")
    private Double tmdbRating;

    @Column(name = "imdb_rating")
    private Double imdbRating;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (isFree == null) {
            isFree = (price == null || price.compareTo(BigDecimal.ZERO) <= 0);
        }
    }
}

