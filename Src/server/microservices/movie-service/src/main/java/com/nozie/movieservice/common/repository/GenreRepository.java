package com.nozie.movieservice.common.repository;

import com.nozie.movieservice.common.model.Genre;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GenreRepository extends MongoRepository<Genre, String> {

    Optional<Genre> findBySlug(String slug);

    boolean existsBySlug(String slug);
}
