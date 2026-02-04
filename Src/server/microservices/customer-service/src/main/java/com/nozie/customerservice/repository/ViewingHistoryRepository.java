package com.nozie.customerservice.repository;

import com.nozie.customerservice.model.ViewingHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ViewingHistoryRepository extends JpaRepository<ViewingHistory, Long> {

    List<ViewingHistory> findByCustomerIdOrderByWatchedAtDesc(Long customerId, Pageable pageable);

    Page<ViewingHistory> findByCustomerId(Long customerId, Pageable pageable);
}
