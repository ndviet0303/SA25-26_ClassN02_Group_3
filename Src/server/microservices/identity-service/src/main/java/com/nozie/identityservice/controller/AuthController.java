package com.nozie.identityservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.identityservice.dto.request.*;
import com.nozie.identityservice.dto.response.*;
import com.nozie.identityservice.entity.User;
import com.nozie.identityservice.entity.UserSession;
import com.nozie.identityservice.service.AuthService;
import com.nozie.identityservice.service.TokenService;
import com.nozie.identityservice.service.UserService;
import com.nozie.identityservice.mapper.UserMapper;
import com.nozie.identityservice.repository.UserSessionRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;
    private final TokenService tokenService;
    private final UserSessionRepository userSessionRepository;
    private final UserService userService;
    private final UserMapper userMapper;

    public AuthController(AuthService authService, TokenService tokenService,
            UserSessionRepository userSessionRepository, UserService userService,
            UserMapper userMapper) {
        this.authService = authService;
        this.tokenService = tokenService;
        this.userSessionRepository = userSessionRepository;
        this.userService = userService;
        this.userMapper = userMapper;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponse>> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest httpRequest) {
        log.info("POST /api/auth/register - Registering user: {}", request.getUsername());

        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        User user = authService.register(request, ipAddress, userAgent);
        return new ResponseEntity<>(
                ApiResponse.success("User registered successfully", userMapper.toUserResponse(user)),
                HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {
        log.info("POST /api/auth/login - Login attempt: {}", request.getUsername());

        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");
        String deviceInfo = httpRequest.getHeader("X-Device-Info");

        AuthResponse authResponse = authService.login(request, ipAddress, userAgent, deviceInfo);
        return ResponseEntity.ok(ApiResponse.success("Login successful", authResponse));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestBody RefreshTokenRequest request,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            HttpServletRequest httpRequest) {
        log.info("POST /api/auth/logout");

        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");
        String accessToken = null;

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            accessToken = authHeader.substring(7);
        }

        authService.logout(request.getRefreshToken(), accessToken, ipAddress, userAgent);
        return ResponseEntity.ok(ApiResponse.success("Logged out successfully", null));
    }

    @PostMapping("/logout-all")
    public ResponseEntity<ApiResponse<Void>> logoutAll(
            @RequestHeader("Authorization") String authHeader,
            HttpServletRequest httpRequest) {
        log.info("POST /api/auth/logout-all");

        String token = authHeader.substring(7);
        Long userId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        authService.logoutAll(userId, ipAddress, userAgent);
        return ResponseEntity.ok(ApiResponse.success("All sessions logged out", null));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request,
            HttpServletRequest httpRequest) {
        log.info("POST /api/auth/refresh");

        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        AuthResponse authResponse = authService.refreshToken(request.getRefreshToken(), ipAddress, userAgent);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed", authResponse));
    }

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody ChangePasswordRequest request,
            HttpServletRequest httpRequest) {
        log.info("POST /api/auth/change-password");

        String token = authHeader.substring(7);
        Long userId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        authService.changePassword(userId, request, ipAddress, userAgent);
        return ResponseEntity.ok(ApiResponse.success("Password changed successfully", null));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UpdateProfileRequest request,
            HttpServletRequest httpRequest) {
        log.info("PUT /api/auth/profile");

        String token = authHeader.substring(7);
        Long userId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        User user = userService.updateProfile(userId, request, ipAddress, userAgent);

        return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", userMapper.toUserResponse(user)));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(
            @RequestHeader("Authorization") String authHeader) {
        log.info("GET /api/auth/me");

        String token = authHeader.substring(7);
        Long userId = tokenService.getUserIdFromToken(token);
        User user = authService.getUserById(userId);

        return ResponseEntity.ok(ApiResponse.success(userMapper.toUserResponse(user)));
    }

    @GetMapping("/sessions")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getSessions(
            @RequestHeader("Authorization") String authHeader) {
        log.info("GET /api/auth/sessions");

        String token = authHeader.substring(7);
        Long userId = tokenService.getUserIdFromToken(token);

        List<UserSession> sessions = userSessionRepository.findByUserIdAndIsActiveTrue(userId);

        List<Map<String, Object>> sessionData = sessions.stream()
                .map(session -> Map.<String, Object>of(
                        "id", session.getId(),
                        "deviceInfo", session.getDeviceInfo() != null ? session.getDeviceInfo() : "",
                        "ipAddress", session.getIpAddress() != null ? session.getIpAddress() : "",
                        "lastAccessAt", session.getLastAccessAt().toString(),
                        "createdAt", session.getCreatedAt().toString()))
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(sessionData));
    }

    @DeleteMapping("/sessions/{sessionId}")
    public ResponseEntity<ApiResponse<Void>> revokeSession(
            @PathVariable Long sessionId,
            @RequestHeader("Authorization") String authHeader,
            HttpServletRequest httpRequest) {
        log.info("DELETE /api/auth/sessions/{}", sessionId);

        String token = authHeader.substring(7);
        Long userId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");
        log.info("DELETE /api/auth/sessions/{} from {} using {}", sessionId, ipAddress, userAgent);

        UserSession session = userSessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session not found"));

        if (!session.getUserId().equals(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Cannot revoke session of another user"));
        }

        session.deactivate();
        userSessionRepository.save(session);

        return ResponseEntity.ok(ApiResponse.success("Session revoked", null));
    }

    @GetMapping("/validate")
    public ResponseEntity<ApiResponse<Map<String, Object>>> validateToken(
            @RequestHeader("Authorization") String authHeader) {
        log.info("GET /api/auth/validate");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Invalid token format"));
        }

        String token = authHeader.substring(7);

        try {
            var claims = tokenService.validateAccessToken(token);

            Map<String, Object> tokenInfo = Map.of(
                    "userId", claims.getSubject(),
                    "username", claims.get("username", String.class),
                    "roles", claims.get("roles"),
                    "permissions", claims.get("permissions"),
                    "valid", true);

            return ResponseEntity.ok(ApiResponse.success(tokenInfo));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Invalid or expired token"));
        }
    }

    private String getClientIP(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIP = request.getHeader("X-Real-IP");
        if (xRealIP != null && !xRealIP.isEmpty()) {
            return xRealIP;
        }
        return request.getRemoteAddr();
    }
}
