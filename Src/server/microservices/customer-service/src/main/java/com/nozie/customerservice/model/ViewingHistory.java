package com.nozie.customerservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * UC19: Track Viewing History – Record when a customer watches a movie.
 */
@Entity
@Table(name = "viewing_history", indexes = {
    @Index(columnList = "customer_id, watched_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ViewingHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "movie_id", nullable = false)
    private String movieId;

    @Column(name = "watched_at")
    @Builder.Default
    private LocalDateTime watchedAt = LocalDateTime.now();

    @Column(name = "progress_seconds")
    private Integer progressSeconds;
}
