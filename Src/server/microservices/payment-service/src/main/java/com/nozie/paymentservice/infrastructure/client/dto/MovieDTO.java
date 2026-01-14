package com.nozie.paymentservice.infrastructure.client.dto;

import lombok.*;
import java.math.BigDecimal;

/**
 * Minimal Movie DTO for inter-service communication.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieDTO {
    private String id;
    private String title;
    private BigDecimal price;
}
