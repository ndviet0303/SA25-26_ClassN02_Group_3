package com.nozie.identityservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.identityservice.dto.*;
import com.nozie.identityservice.entity.*;
import com.nozie.identityservice.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class AuthService {

    @Value("${jwt.access-token-expiration:900000}")
    private long accessTokenExpiration;

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final AuditService auditService;
    private final UserSessionRepository userSessionRepository;

    public User register(RegisterRequest request, String ipAddress, String userAgent) {
        log.info("Registering user: {}", request.getUsername());

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username '" + request.getUsername() + "' already exists");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setStatus(User.Status.ACTIVE);

        // Assign default USER role
        Role userRole = roleRepository.findByName("USER")
                .orElseGet(() -> {
                    Role newRole = new Role("USER", "Default user role");
                    return roleRepository.save(newRole);
                });
        user.addRole(userRole);

        User savedUser = userRepository.save(user);

        auditService.logSuccess(savedUser.getId(), AuditLog.Action.REGISTER, ipAddress, userAgent);

        return savedUser;
    }

    public AuthResponse login(LoginRequest request, String ipAddress, String userAgent, String deviceInfo) {
        log.info("Login attempt for user: {}", request.getUsername());

        User user = userRepository.findByUsernameOrEmail(request.getUsername(), request.getUsername())
                .orElseThrow(() -> {
                    auditService.logFailure(null, AuditLog.Action.LOGIN_FAILED, ipAddress, userAgent,
                            "User not found: " + request.getUsername());
                    return new BadRequestException("Invalid username or password");
                });

        // Check account status
        if (user.isAccountLocked()) {
            auditService.logFailure(user.getId(), AuditLog.Action.LOGIN_FAILED, ipAddress, userAgent,
                    "Account is locked until " + user.getLockedUntil());
            throw new BadRequestException("Account is locked. Try again after " + user.getLockedUntil());
        }

        if (user.getStatus() == User.Status.DISABLED) {
            auditService.logFailure(user.getId(), AuditLog.Action.LOGIN_FAILED, ipAddress, userAgent,
                    "Account is disabled");
            throw new BadRequestException("Account is disabled. Please contact support.");
        }

        // Verify password
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            user.incrementFailedAttempts();
            userRepository.save(user);

            auditService.logFailure(user.getId(), AuditLog.Action.LOGIN_FAILED, ipAddress, userAgent,
                    "Invalid password. Attempts: " + user.getFailedLoginAttempts());
            throw new BadRequestException("Invalid username or password");
        }

        // Successful login
        user.recordLogin(ipAddress);
        userRepository.save(user);

        // Generate tokens
        String accessToken = tokenService.generateAccessToken(user);
        RefreshToken refreshToken = tokenService.generateRefreshToken(user, deviceInfo, ipAddress, userAgent);

        // Create session
        UserSession session = new UserSession(user.getId(), refreshToken.getId(), deviceInfo, ipAddress);
        session.setUserAgent(userAgent);
        userSessionRepository.save(session);

        auditService.logSuccess(user.getId(), AuditLog.Action.LOGIN, ipAddress, userAgent);

        // Build response
        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        Set<String> permissions = user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(Permission::getName)
                .collect(Collectors.toSet());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken.getToken())
                .expiresIn(accessTokenExpiration / 1000)
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .roles(roles)
                .permissions(permissions)
                .build();
    }

    public void logout(String refreshToken, String accessToken, String ipAddress, String userAgent) {
        log.info("Logout request");

        RefreshToken token = tokenService.validateRefreshToken(refreshToken);

        // Revoke refresh token
        tokenService.revokeRefreshToken(refreshToken, "User logout");

        // Deactivate session
        userSessionRepository.findByRefreshTokenId(token.getId())
                .ifPresent(session -> {
                    session.deactivate();
                    userSessionRepository.save(session);
                });

        // Blacklist access token if provided
        if (accessToken != null && !accessToken.isEmpty()) {
            try {
                String jti = tokenService.getJtiFromToken(accessToken);
                LocalDateTime expiration = tokenService.getExpirationFromToken(accessToken);
                tokenService.blacklistAccessToken(jti, token.getUserId(), expiration, "User logout");
            } catch (Exception e) {
                log.warn("Could not blacklist access token: {}", e.getMessage());
            }
        }

        auditService.logSuccess(token.getUserId(), AuditLog.Action.LOGOUT, ipAddress, userAgent);
    }

    public void logoutAll(Long userId, String ipAddress, String userAgent) {
        log.info("Logout all sessions for user: {}", userId);

        tokenService.revokeAllUserTokens(userId, "Logout all sessions");
        userSessionRepository.deactivateAllByUserId(userId);

        auditService.logSuccess(userId, AuditLog.Action.LOGOUT_ALL, ipAddress, userAgent);
    }

    public AuthResponse refreshToken(String refreshToken, String ipAddress, String userAgent) {
        log.info("Refreshing token");

        // Validate and rotate refresh token
        RefreshToken newRefreshToken = tokenService.rotateRefreshToken(refreshToken, ipAddress, userAgent);

        User user = userRepository.findById(newRefreshToken.getUserId())
                .orElseThrow(() -> new BadRequestException("User not found"));

        // Generate new access token
        String accessToken = tokenService.generateAccessToken(user);

        // Update session
        userSessionRepository.findByRefreshTokenId(newRefreshToken.getId())
                .ifPresent(session -> {
                    session.updateLastAccess();
                    userSessionRepository.save(session);
                });

        auditService.logSuccess(user.getId(), AuditLog.Action.TOKEN_REFRESH, ipAddress, userAgent);

        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        Set<String> permissions = user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(Permission::getName)
                .collect(Collectors.toSet());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(newRefreshToken.getToken())
                .expiresIn(accessTokenExpiration / 1000)
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .roles(roles)
                .permissions(permissions)
                .build();
    }

    public void changePassword(Long userId, ChangePasswordRequest request, String ipAddress, String userAgent) {
        log.info("Changing password for user: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("User not found"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            auditService.logFailure(userId, AuditLog.Action.PASSWORD_CHANGE, ipAddress, userAgent,
                    "Invalid current password");
            throw new BadRequestException("Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordChangedAt(LocalDateTime.now());
        userRepository.save(user);

        // Force logout all sessions if requested
        if (request.isLogoutAllSessions()) {
            tokenService.revokeAllUserTokens(userId, "Password changed");
            userSessionRepository.deactivateAllByUserId(userId);
        }

        auditService.logSuccess(userId, AuditLog.Action.PASSWORD_CHANGE, ipAddress, userAgent);
    }

    @Transactional(readOnly = true)
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("User not found"));
    }

    @Transactional(readOnly = true)
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BadRequestException("User not found"));
    }
}
