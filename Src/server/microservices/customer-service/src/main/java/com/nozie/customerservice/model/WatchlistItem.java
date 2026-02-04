package com.nozie.customerservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * UC12: Add to Watchlist – Customer's saved movie IDs.
 */
@Entity
@Table(name = "watchlist_items", uniqueConstraints = {
    @UniqueConstraint(columnNames = { "customer_id", "movie_id" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WatchlistItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "movie_id", nullable = false)
    private String movieId;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
