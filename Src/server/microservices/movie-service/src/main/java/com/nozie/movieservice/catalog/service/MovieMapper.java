package com.nozie.movieservice.catalog.service;

import com.nozie.movieservice.common.dto.MovieListItemResponse;
import com.nozie.movieservice.common.dto.MovieResponse;
import com.nozie.movieservice.common.model.Movie;
import org.springframework.stereotype.Component;

@Component
public class MovieMapper {

    public MovieListItemResponse toListItem(Movie m) {
        if (m == null) return null;
        return MovieListItemResponse.builder()
                .id(m.getId())
                .name(m.getName())
                .originName(m.getOriginName())
                .slug(m.getSlug())
                .thumbUrl(m.getThumbUrl())
                .posterUrl(m.getPosterUrl())
                .type(m.getType())
                .quality(m.getQuality())
                .lang(m.getLang())
                .year(m.getYear())
                .view(m.getView())
                .time(m.getTime())
                .episodeCurrent(m.getEpisodeCurrent())
                .tmdbRating(m.getTmdbRating())
                .imdbRating(m.getImdbRating())
                .category(m.getCategory())
                .country(m.getCountry())
                .accessType(m.getAccessType() != null ? m.getAccessType().name() : null)
                .build();
    }

    public MovieResponse toResponse(Movie m) {
        if (m == null) return null;
        return MovieResponse.builder()
                .id(m.getId())
                .externalId(m.getExternalId())
                .name(m.getName())
                .originName(m.getOriginName())
                .slug(m.getSlug())
                .content(m.getContent())
                .thumbUrl(m.getThumbUrl())
                .posterUrl(m.getPosterUrl())
                .trailerUrl(m.getTrailerUrl())
                .type(m.getType())
                .status(m.getStatus())
                .quality(m.getQuality())
                .lang(m.getLang())
                .year(m.getYear())
                .view(m.getView())
                .time(m.getTime())
                .episodeCurrent(m.getEpisodeCurrent())
                .episodeTotal(m.getEpisodeTotal())
                .price(m.getPrice())
                .accessType(m.getAccessType() != null ? m.getAccessType().name() : null)
                .tmdbRating(m.getTmdbRating())
                .imdbRating(m.getImdbRating())
                .category(m.getCategory())
                .country(m.getCountry())
                .alternativeNames(m.getAlternativeNames())
                .actor(m.getActor())
                .director(m.getDirector())
                .episodes(m.getEpisodes())
                .customHlsUrl(m.getCustomHlsUrl())
                .customHlsSource(m.getCustomHlsSource())
                .build();
    }
}
