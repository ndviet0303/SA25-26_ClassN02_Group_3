package com.nozie.identityservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.identityservice.dto.AuthResponse;
import com.nozie.identityservice.dto.LoginRequest;
import com.nozie.identityservice.dto.RegisterRequest;
import com.nozie.identityservice.entity.User;
import com.nozie.identityservice.service.AuthService;
import com.nozie.identityservice.service.JwtService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;
    private final JwtService jwtService;

    public AuthController(AuthService authService, JwtService jwtService) {
        this.authService = authService;
        this.jwtService = jwtService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Map<String, Object>>> register(@Valid @RequestBody RegisterRequest request) {
        log.info("POST /api/auth/register - Registering user: {}", request.getUsername());
        User user = authService.register(request);
        Map<String, Object> userData = Map.of(
            "id", user.getId(),
            "username", user.getUsername(),
            "role", user.getRole()
        );
        return new ResponseEntity<>(ApiResponse.success("User registered successfully", userData), HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        log.info("POST /api/auth/login - Login attempt: {}", request.getUsername());
        AuthResponse authResponse = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", authResponse));
    }

    @GetMapping("/validate")
    public ResponseEntity<ApiResponse<Map<String, Object>>> validateToken(
            @RequestHeader("Authorization") String authHeader) {
        log.info("GET /api/auth/validate - Validating token");
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Invalid token format"));
        }

        String token = authHeader.substring(7);
        
        if (!jwtService.validateToken(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Invalid or expired token"));
        }

        Long userId = jwtService.getUserIdFromToken(token);
        String username = jwtService.getUsernameFromToken(token);
        String role = jwtService.getRoleFromToken(token);

        Map<String, Object> tokenInfo = Map.of(
            "userId", userId,
            "username", username,
            "role", role,
            "valid", true
        );

        return ResponseEntity.ok(ApiResponse.success(tokenInfo));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCurrentUser(
            @RequestHeader("Authorization") String authHeader) {
        log.info("GET /api/auth/me - Getting current user");
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Invalid token format"));
        }

        String token = authHeader.substring(7);
        
        if (!jwtService.validateToken(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Invalid or expired token"));
        }

        Long userId = jwtService.getUserIdFromToken(token);
        User user = authService.getUserById(userId);

        Map<String, Object> userData = Map.of(
            "id", user.getId(),
            "username", user.getUsername(),
            "role", user.getRole(),
            "createdAt", user.getCreatedAt().toString()
        );

        return ResponseEntity.ok(ApiResponse.success(userData));
    }
}
