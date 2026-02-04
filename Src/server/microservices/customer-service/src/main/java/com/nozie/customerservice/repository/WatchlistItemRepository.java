package com.nozie.customerservice.repository;

import com.nozie.customerservice.model.WatchlistItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WatchlistItemRepository extends JpaRepository<WatchlistItem, Long> {

    List<WatchlistItem> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    Optional<WatchlistItem> findByCustomerIdAndMovieId(Long customerId, String movieId);

    boolean existsByCustomerIdAndMovieId(Long customerId, String movieId);

    void deleteByCustomerIdAndMovieId(Long customerId, String movieId);
}
