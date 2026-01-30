package com.nozie.movieservice.common.dto;

import com.nozie.movieservice.common.model.CategoryRef;
import com.nozie.movieservice.common.model.CountryRef;
import com.nozie.movieservice.common.model.Episode;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
public class MovieResponse {

    private String id;
    private String externalId;
    private String name;
    private String originName;
    private String slug;
    private String content;
    private String thumbUrl;
    private String posterUrl;
    private String trailerUrl;
    private String type;
    private String status;
    private String quality;
    private String lang;
    private Integer year;
    private Long view;
    private String time;
    private String episodeCurrent;
    private String episodeTotal;
    private BigDecimal price;
    private String accessType;
    private Double tmdbRating;
    private Double imdbRating;
    private List<CategoryRef> category;
    private List<CountryRef> country;
    private List<String> alternativeNames;
    private List<String> actor;
    private List<String> director;
    private List<Episode> episodes;
    private String customHlsUrl;
    private String customHlsSource;
}
