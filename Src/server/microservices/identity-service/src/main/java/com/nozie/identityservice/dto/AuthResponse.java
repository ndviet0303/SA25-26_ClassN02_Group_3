package com.nozie.identityservice.dto;

import lombok.*;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {

    private String accessToken;
    private String refreshToken;

    @Builder.Default
    private String tokenType = "Bearer";

    private long expiresIn; // Access token expiration in seconds
    private Long userId;
    private String username;
    private String email;
    private Set<String> roles;
    private Set<String> permissions;
}
