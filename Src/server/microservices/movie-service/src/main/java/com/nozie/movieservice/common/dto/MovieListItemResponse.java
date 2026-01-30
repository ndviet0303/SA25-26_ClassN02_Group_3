package com.nozie.movieservice.common.dto;

import com.nozie.movieservice.common.model.CategoryRef;
import com.nozie.movieservice.common.model.CountryRef;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class MovieListItemResponse {

    private String id;
    private String name;
    private String originName;
    private String slug;
    private String thumbUrl;
    private String posterUrl;
    private String type;
    private String quality;
    private String lang;
    private Integer year;
    private Long view;
    private String time;
    private String episodeCurrent;
    private Double tmdbRating;
    private Double imdbRating;
    private List<CategoryRef> category;
    private List<CountryRef> country;
    private String accessType;
}
