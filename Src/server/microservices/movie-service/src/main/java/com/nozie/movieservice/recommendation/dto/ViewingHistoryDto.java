package com.nozie.movieservice.recommendation.dto;

import lombok.*;

/**
 * DTO for viewing history items from Customer Service
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ViewingHistoryDto {
    private Long id;
    private Long customerId;
    private String movieId;
    private String watchedAt;
    private Integer progressSeconds;
}
