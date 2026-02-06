package com.nozie.identityservice.dto.request;

import lombok.*;
import jakarta.validation.constraints.*;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterRequest {

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    // Profile fields - passed to Customer Service via UserRegisteredEvent
    private String fullName;
    private String phoneNumber;
    private String dateOfBirth;
    private String gender;
    private String country;
    private String avatarUrl;
    private String bio;
    private List<String> genres; // Initial interests
}
