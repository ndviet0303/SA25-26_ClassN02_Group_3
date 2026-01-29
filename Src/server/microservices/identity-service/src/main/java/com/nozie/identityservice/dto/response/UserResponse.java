package com.nozie.identityservice.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String username;
    private String email;
    private String status;
    private Set<String> roles;
    private Set<String> permissions;
    private String lastLoginAt;
    private String createdAt;

    // Profile information
    private String fullName;
    private String avatarUrl;
    private String phone;
    private String country;
    private String dateOfBirth;
    private String gender;
    private String age;
    private Set<String> genres;
}
