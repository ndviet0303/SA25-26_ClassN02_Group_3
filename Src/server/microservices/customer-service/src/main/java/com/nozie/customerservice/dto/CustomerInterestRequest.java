package com.nozie.customerservice.dto;

import lombok.*;
import java.util.List;

/**
 * Customer Interest Request DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerInterestRequest {
    private List<String> genreSlugs;
}
