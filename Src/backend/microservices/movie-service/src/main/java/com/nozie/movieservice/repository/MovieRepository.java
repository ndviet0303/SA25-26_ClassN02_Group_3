package com.nozie.movieservice.repository;

import com.nozie.movieservice.model.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Layer 3: Persistence Layer - Movie Repository
 */
@Repository
public interface MovieRepository extends JpaRepository<Movie, Long> {

    Optional<Movie> findBySlug(String slug);

    List<Movie> findByType(String type);

    List<Movie> findByIsFreeTrue();

    List<Movie> findTop10ByOrderByViewDesc();

    @Query("SELECT m FROM Movie m WHERE LOWER(m.name) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(m.originName) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Movie> searchByKeyword(@Param("keyword") String keyword);

    boolean existsBySlug(String slug);
}

