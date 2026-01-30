package com.nozie.movieservice.common.repository;

import com.nozie.movieservice.common.model.Movie;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MovieRepository extends MongoRepository<Movie, String>, MovieRepositoryCustom {

    Optional<Movie> findBySlug(String slug);

    List<Movie> findByType(String type);

    List<Movie> findByAccessType(Movie.AccessType accessType);

    List<Movie> findTop10ByOrderByViewDesc();

    List<Movie> findByNameContainingIgnoreCaseOrOriginNameContainingIgnoreCase(String name, String originName);

    boolean existsBySlug(String slug);
}
