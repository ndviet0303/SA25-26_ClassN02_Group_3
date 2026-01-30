package com.nozie.movieservice.common.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Movie Document - metadata + episodes. MongoDB dùng camelCase (khớp với tools/import.js).
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
    private String externalId;

    @NotBlank(message = "Movie name is required")
    private String name;
    private String originName;

    @NotBlank(message = "Slug is required")
    @Indexed(unique = true)
    private String slug;

    private String content;
    private String posterUrl;
    private String thumbUrl;
    private String trailerUrl;

    private String type;
    private String status;
    private String quality;
    private String lang;
    private List<String> langKey;
    private Integer year;

    @Builder.Default
    private Long view = 0L;

    private String time;
    private String episodeCurrent;
    private String episodeTotal;

    @Builder.Default
    private BigDecimal price = BigDecimal.ZERO;

    @Builder.Default
    private AccessType accessType = AccessType.FREE;

    private Double tmdbRating;
    private Double imdbRating;

    private List<CategoryRef> category;
    private List<CountryRef> country;
    private List<String> alternativeNames;

    private List<String> actor;
    private List<String> director;
    private Boolean subDocquyen;
    private Boolean chieuRap;

    private List<Episode> episodes;

    @Builder.Default
    private Source source = Source.OPHIM;
    private String customHlsUrl;
    private String customHlsSource;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime updatedAt;

    public void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum AccessType {
        FREE,
        PREMIUM,
        RENTAL
    }

    public enum Source {
        OPHIM,
        MANUAL
    }
}
