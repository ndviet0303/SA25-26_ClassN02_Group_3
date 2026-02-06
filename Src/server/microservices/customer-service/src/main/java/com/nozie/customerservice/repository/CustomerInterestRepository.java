package com.nozie.customerservice.repository;

import com.nozie.customerservice.model.CustomerInterest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerInterestRepository extends JpaRepository<CustomerInterest, Long> {

    List<CustomerInterest> findByCustomerId(Long customerId);

    boolean existsByCustomerIdAndGenreSlug(Long customerId, String genreSlug);

    void deleteByCustomerIdAndGenreSlug(Long customerId, String genreSlug);

    void deleteByCustomerId(Long customerId);
}
