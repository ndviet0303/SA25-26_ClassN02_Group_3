package com.nozie.customerservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.customerservice.dto.CustomerInterestRequest;
import com.nozie.customerservice.dto.CustomerRequest;
import com.nozie.customerservice.model.*;
import com.nozie.customerservice.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final CustomerInterestRepository interestRepository;
    private final WatchlistItemRepository watchlistRepository;
    private final ViewingHistoryRepository historyRepository;

    public List<Customer> getAllCustomers() {
        return customerRepository.findAll();
    }

    public Customer getCustomerById(Long id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Customer not found with ID: " + id));
    }

    public Customer getCustomerByUserId(Long userId) {
        return customerRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Customer not found for user ID: " + userId));
    }

    public Customer createCustomer(CustomerRequest request) {
        log.info("Creating customer for user ID: {}", request.getUserId());

        if (customerRepository.existsByUserId(request.getUserId())) {
            throw new BadRequestException("Customer for user ID '" + request.getUserId() + "' already exists");
        }

        Customer customer = Customer.builder()
                .userId(request.getUserId())
                .fullName(request.getFullName())
                .dateOfBirth(request.getDateOfBirth())
                .gender(request.getGender())
                .avatarUrl(request.getAvatarUrl())
                .country(request.getCountry())
                .bio(request.getBio())
                .phoneNumber(request.getPhoneNumber())
                .build();

        Customer saved = customerRepository.save(customer);
        log.info("Created customer with ID: {} for user: {}", saved.getId(), request.getFullName());
        return saved;
    }

    public Customer updateCustomer(Long id, CustomerRequest request) {
        Customer customer = getCustomerById(id);
        return updateFields(customer, request);
    }

    public Customer updateCustomerByUserId(Long userId, CustomerRequest request) {
        Customer customer = getCustomerByUserId(userId);
        return updateFields(customer, request);
    }

    private Customer updateFields(Customer customer, CustomerRequest request) {
        if (request.getFullName() != null)
            customer.setFullName(request.getFullName());
        if (request.getDateOfBirth() != null)
            customer.setDateOfBirth(request.getDateOfBirth());
        if (request.getGender() != null)
            customer.setGender(request.getGender());
        if (request.getAvatarUrl() != null)
            customer.setAvatarUrl(request.getAvatarUrl());
        if (request.getCountry() != null)
            customer.setCountry(request.getCountry());
        if (request.getBio() != null)
            customer.setBio(request.getBio());
        if (request.getPhoneNumber() != null)
            customer.setPhoneNumber(request.getPhoneNumber());

        return customerRepository.save(customer);
    }

    public void deleteCustomer(Long id) {
        Customer customer = getCustomerById(id);
        customerRepository.delete(customer);
        log.info("Deleted customer with ID: {}", id);
    }

    public Customer updateSubscription(Long id, boolean isSubscribed) {
        Customer customer = getCustomerById(id);
        customer.setIsSubscribed(isSubscribed);
        return customerRepository.save(customer);
    }

    // ========== Interest Methods ==========

    public List<CustomerInterest> getInterests(Long customerId) {
        return interestRepository.findByCustomerId(customerId);
    }

    public List<CustomerInterest> setInterests(Long customerId, CustomerInterestRequest request) {
        interestRepository.deleteByCustomerId(customerId);

        List<CustomerInterest> interests = request.getGenreSlugs().stream()
                .map(slug -> CustomerInterest.builder()
                        .customerId(customerId)
                        .genreSlug(slug)
                        .build())
                .collect(Collectors.toList());

        return interestRepository.saveAll(interests);
    }

    public CustomerInterest addInterest(Long customerId, String genreSlug) {
        if (interestRepository.existsByCustomerIdAndGenreSlug(customerId, genreSlug)) {
            return null;
        }
        CustomerInterest interest = CustomerInterest.builder()
                .customerId(customerId)
                .genreSlug(genreSlug)
                .build();
        return interestRepository.save(interest);
    }

    public void removeInterest(Long customerId, String genreSlug) {
        interestRepository.deleteByCustomerIdAndGenreSlug(customerId, genreSlug);
    }

    // ========== Watchlist Methods ==========

    public List<WatchlistItem> getWatchlist(Long customerId) {
        return watchlistRepository.findByCustomerIdOrderByCreatedAtDesc(customerId);
    }

    public WatchlistItem addToWatchlist(Long customerId, String movieId) {
        return watchlistRepository.findByCustomerIdAndMovieId(customerId, movieId)
                .orElseGet(() -> watchlistRepository.save(WatchlistItem.builder()
                        .customerId(customerId)
                        .movieId(movieId)
                        .build()));
    }

    public void removeFromWatchlist(Long customerId, String movieId) {
        watchlistRepository.deleteByCustomerIdAndMovieId(customerId, movieId);
    }

    // ========== Viewing History Methods ==========

    public List<ViewingHistory> getViewingHistory(Long customerId, int limit) {
        return historyRepository.findByCustomerIdOrderByWatchedAtDesc(customerId, PageRequest.of(0, limit));
    }

    public ViewingHistory recordViewing(Long customerId, String movieId, Integer progress) {
        ViewingHistory history = ViewingHistory.builder()
                .customerId(customerId)
                .movieId(movieId)
                .progressSeconds(progress)
                .watchedAt(LocalDateTime.now())
                .build();
        return historyRepository.save(history);
    }
}
