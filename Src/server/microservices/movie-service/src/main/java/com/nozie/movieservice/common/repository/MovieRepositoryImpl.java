package com.nozie.movieservice.common.repository;

import com.nozie.movieservice.common.model.Movie;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.regex.Pattern;

@Repository
@RequiredArgsConstructor
public class MovieRepositoryImpl implements MovieRepositoryCustom {

    private final MongoTemplate mongoTemplate;

    @Override
    public Page<Movie> findWithFilter(String type, String genreSlug, String countrySlug,
                                      Integer year, String keyword, Pageable pageable) {
        Query q = new Query();
        if (type != null && !type.isBlank()) {
            q.addCriteria(Criteria.where("type").is(type));
        }
        if (genreSlug != null && !genreSlug.isBlank()) {
            q.addCriteria(Criteria.where("category.slug").is(genreSlug));
        }
        if (countrySlug != null && !countrySlug.isBlank()) {
            q.addCriteria(Criteria.where("country.slug").is(countrySlug));
        }
        if (year != null) {
            q.addCriteria(Criteria.where("year").is(year));
        }
        if (keyword != null && !keyword.isBlank()) {
            Pattern p = Pattern.compile(Pattern.quote(keyword), Pattern.CASE_INSENSITIVE);
            q.addCriteria(new Criteria().orOperator(
                    Criteria.where("name").regex(p),
                    Criteria.where("originName").regex(p)
            ));
        }
        long total = mongoTemplate.count(q, Movie.class);
        q.with(pageable);
        List<Movie> items = mongoTemplate.find(q, Movie.class);
        return new PageImpl<>(items, pageable, total);
    }

    @Override
    public List<Integer> findDistinctYears() {
        return mongoTemplate.findDistinct(new Query(), "year", Movie.class, Integer.class);
    }
}
