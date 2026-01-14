package com.nozie.identityservice.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "token_blacklist")
public class TokenBlacklist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String jti; // JWT ID

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "token_type")
    private String tokenType; // ACCESS or REFRESH

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    private String reason;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public TokenBlacklist() {
    }

    public TokenBlacklist(String jti, Long userId, String tokenType, LocalDateTime expiresAt, String reason) {
        this.jti = jti;
        this.userId = userId;
        this.tokenType = tokenType;
        this.expiresAt = expiresAt;
        this.reason = reason;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getJti() {
        return jti;
    }

    public void setJti(String jti) {
        this.jti = jti;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
