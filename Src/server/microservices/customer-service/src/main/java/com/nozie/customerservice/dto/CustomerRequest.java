package com.nozie.customerservice.dto;

import lombok.*;
import jakarta.validation.constraints.*;

/**
 * Customer Request DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerRequest {

    private String firebaseUid;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    private String fullName;
    private String phoneNumber;
    private String avatarUrl;
    private String dateOfBirth;
    private String gender;
}
