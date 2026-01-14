package com.nozie.paymentservice.infrastructure.client.dto;

import lombok.*;

/**
 * Minimal Customer DTO for inter-service communication.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerDTO {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
}
