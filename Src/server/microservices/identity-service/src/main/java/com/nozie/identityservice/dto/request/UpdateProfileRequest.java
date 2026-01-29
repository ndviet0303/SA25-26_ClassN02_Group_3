package com.nozie.identityservice.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {
    private String fullName;
    private String dateOfBirth;
    private String country;
    private String gender;
    private String age;
    private String avatarUrl;
    private Set<String> genres;
    private String phone;
}
