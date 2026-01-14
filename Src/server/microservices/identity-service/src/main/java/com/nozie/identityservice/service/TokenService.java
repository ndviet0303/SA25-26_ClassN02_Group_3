package com.nozie.identityservice.service;

import com.nozie.identityservice.entity.RefreshToken;
import com.nozie.identityservice.entity.TokenBlacklist;
import com.nozie.identityservice.entity.User;
import com.nozie.identityservice.entity.Role;
import com.nozie.identityservice.repository.RefreshTokenRepository;
import com.nozie.identityservice.repository.TokenBlacklistRepository;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class TokenService {

    private static final Logger log = LoggerFactory.getLogger(TokenService.class);

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.access-token-expiration:900000}") // 15 minutes
    private long accessTokenExpiration;

    @Value("${jwt.refresh-token-expiration:604800000}") // 7 days
    private long refreshTokenExpiration;

    private final RefreshTokenRepository refreshTokenRepository;
    private final TokenBlacklistRepository tokenBlacklistRepository;

    public TokenService(RefreshTokenRepository refreshTokenRepository,
            TokenBlacklistRepository tokenBlacklistRepository) {
        this.refreshTokenRepository = refreshTokenRepository;
        this.tokenBlacklistRepository = tokenBlacklistRepository;
    }

    /**
     * Generate Access Token (short-lived, 15 minutes)
     */
    public String generateAccessToken(User user) {
        String jti = UUID.randomUUID().toString();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + accessTokenExpiration);

        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        Set<String> permissions = user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(p -> p.getName())
                .collect(Collectors.toSet());

        return Jwts.builder()
                .id(jti)
                .subject(String.valueOf(user.getId()))
                .claim("username", user.getUsername())
                .claim("email", user.getEmail())
                .claim("roles", roles)
                .claim("permissions", permissions)
                .claim("type", "ACCESS")
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();
    }

    /**
     * Generate Refresh Token (long-lived, 7 days) and store in database
     */
    public RefreshToken generateRefreshToken(User user, String deviceInfo, String ipAddress, String userAgent) {
        String tokenValue = UUID.randomUUID().toString() + "-" + UUID.randomUUID().toString();
        LocalDateTime expiresAt = LocalDateTime.now().plusSeconds(refreshTokenExpiration / 1000);

        RefreshToken refreshToken = new RefreshToken(
                tokenValue,
                user.getId(),
                deviceInfo,
                ipAddress,
                userAgent,
                expiresAt);

        return refreshTokenRepository.save(refreshToken);
    }

    /**
     * Rotate Refresh Token - revoke old one and issue new one
     */
    public RefreshToken rotateRefreshToken(String oldToken, String ipAddress, String userAgent) {
        RefreshToken oldRefreshToken = refreshTokenRepository.findByToken(oldToken)
                .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));

        if (!oldRefreshToken.isValid()) {
            throw new IllegalArgumentException("Refresh token is expired or revoked");
        }

        // Revoke old token
        oldRefreshToken.revoke("Token rotation");
        refreshTokenRepository.save(oldRefreshToken);

        // Generate new token
        String newTokenValue = UUID.randomUUID().toString() + "-" + UUID.randomUUID().toString();
        LocalDateTime expiresAt = LocalDateTime.now().plusSeconds(refreshTokenExpiration / 1000);

        RefreshToken newRefreshToken = new RefreshToken(
                newTokenValue,
                oldRefreshToken.getUserId(),
                oldRefreshToken.getDeviceInfo(),
                ipAddress,
                userAgent,
                expiresAt);

        return refreshTokenRepository.save(newRefreshToken);
    }

    /**
     * Validate Refresh Token from database
     */
    public RefreshToken validateRefreshToken(String token) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));

        if (!refreshToken.isValid()) {
            throw new IllegalArgumentException("Refresh token is expired or revoked");
        }

        return refreshToken;
    }

    /**
     * Revoke single refresh token
     */
    public void revokeRefreshToken(String token, String reason) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));

        refreshToken.revoke(reason);
        refreshTokenRepository.save(refreshToken);
        log.info("Revoked refresh token for user: {}", refreshToken.getUserId());
    }

    /**
     * Revoke all refresh tokens for a user (logout all sessions)
     */
    public int revokeAllUserTokens(Long userId, String reason) {
        int count = refreshTokenRepository.revokeAllByUserId(userId, LocalDateTime.now(), reason);
        log.info("Revoked {} refresh tokens for user: {}", count, userId);
        return count;
    }

    /**
     * Add Access Token to blacklist
     */
    public void blacklistAccessToken(String jti, Long userId, LocalDateTime expiresAt, String reason) {
        TokenBlacklist blacklist = new TokenBlacklist(jti, userId, "ACCESS", expiresAt, reason);
        tokenBlacklistRepository.save(blacklist);
        log.info("Blacklisted access token {} for user: {}", jti, userId);
    }

    /**
     * Check if token is blacklisted
     */
    public boolean isTokenBlacklisted(String jti) {
        return tokenBlacklistRepository.existsByJti(jti);
    }

    /**
     * Validate Access Token
     */
    public Claims validateAccessToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            // Check if token is blacklisted
            String jti = claims.getId();
            if (jti != null && isTokenBlacklisted(jti)) {
                throw new JwtException("Token has been revoked");
            }

            return claims;
        } catch (JwtException | IllegalArgumentException e) {
            log.error("Token validation failed: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Extract user ID from token
     */
    public Long getUserIdFromToken(String token) {
        Claims claims = validateAccessToken(token);
        return Long.parseLong(claims.getSubject());
    }

    /**
     * Extract JTI from token (for blacklisting)
     */
    public String getJtiFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return claims.getId();
    }

    /**
     * Extract expiration from token
     */
    public LocalDateTime getExpirationFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return claims.getExpiration().toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime();
    }

    /**
     * Get active sessions count for user
     */
    public long getActiveSessionsCount(Long userId) {
        return refreshTokenRepository.countByUserIdAndRevokedAtIsNull(userId);
    }

    /**
     * Cleanup expired tokens (scheduled task)
     */
    public void cleanupExpiredTokens() {
        LocalDateTime now = LocalDateTime.now();
        int deletedRefreshTokens = refreshTokenRepository.deleteExpiredTokens(now);
        int deletedBlacklistTokens = tokenBlacklistRepository.deleteExpiredTokens(now);
        log.info("Cleaned up {} expired refresh tokens and {} blacklist entries",
                deletedRefreshTokens, deletedBlacklistTokens);
    }

    private SecretKey getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
