package com.nozie.movieservice.common.repository;

import com.nozie.movieservice.common.model.MovieReview;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MovieReviewRepository extends MongoRepository<MovieReview, String> {

    List<MovieReview> findByMovieIdOrderByCreatedAtDesc(String movieId, org.springframework.data.domain.Pageable pageable);

    Optional<MovieReview> findByMovieIdAndUserId(String movieId, Long userId);

    long countByMovieId(String movieId);
}
