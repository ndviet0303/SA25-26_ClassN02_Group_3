package com.nozie.movieservice.common.repository;

import com.nozie.movieservice.common.model.Movie;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface MovieRepositoryCustom {

    Page<Movie> findWithFilter(String type, String genreSlug, String countrySlug,
                               Integer year, String keyword, Pageable pageable);

    List<Integer> findDistinctYears();
}
