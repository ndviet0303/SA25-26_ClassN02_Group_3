package com.nozie.movieservice.common.repository;

import com.nozie.movieservice.common.model.Country;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CountryRepository extends MongoRepository<Country, String> {

    Optional<Country> findBySlug(String slug);

    boolean existsBySlug(String slug);
}
