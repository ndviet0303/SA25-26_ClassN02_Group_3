package com.nozie.customerservice.model;

import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Customer Interest Entity - stores customer genre preferences
 */
@Entity
@Table(name = "customer_interests", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "customer_id", "genre_slug" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerInterest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "genre_slug", nullable = false)
    private String genreSlug;

    @Column(name = "genre_name")
    private String genreName;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
