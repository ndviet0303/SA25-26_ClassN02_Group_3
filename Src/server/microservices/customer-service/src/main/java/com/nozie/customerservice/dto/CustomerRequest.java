package com.nozie.customerservice.dto;

import lombok.*;

/**
 * Consolidated Customer Request DTO - for creating/updating everything
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerRequest {

    private Long userId;
    private String fullName;
    private String dateOfBirth;
    private String gender;
    private String avatarUrl;
    private String country;
    private String bio;
    private String phoneNumber;
}
