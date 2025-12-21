package com.nozie.movieservice.repository;

import com.nozie.movieservice.model.Movie;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Layer 3: Persistence Layer - Movie Repository
 */
@Repository
public interface MovieRepository extends MongoRepository<Movie, String> {

    Optional<Movie> findBySlug(String slug);

    List<Movie> findByType(String type);

    List<Movie> findByIsFreeTrue();

    List<Movie> findTop10ByOrderByViewDesc();

    List<Movie> findByNameContainingIgnoreCaseOrOriginNameContainingIgnoreCase(String name, String originName);

    boolean existsBySlug(String slug);
}
