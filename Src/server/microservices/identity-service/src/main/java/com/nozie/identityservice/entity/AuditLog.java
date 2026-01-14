package com.nozie.identityservice.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
public class AuditLog {

    public enum Action {
        LOGIN, LOGIN_FAILED, LOGOUT, LOGOUT_ALL,
        REGISTER, PASSWORD_CHANGE, PASSWORD_RESET,
        TOKEN_REFRESH, TOKEN_REVOKE,
        ROLE_ASSIGN, ROLE_REVOKE,
        USER_LOCK, USER_UNLOCK, USER_DISABLE,
        PERMISSION_GRANT, PERMISSION_REVOKE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "target_user_id")
    private Long targetUserId; // For admin actions on other users

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Action action;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(columnDefinition = "TEXT")
    private String details; // JSON details

    @Column(name = "success")
    private boolean success = true;

    @Column(name = "error_message")
    private String errorMessage;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public AuditLog() {
    }

    public AuditLog(Long userId, Action action, String ipAddress, String userAgent) {
        this.userId = userId;
        this.action = action;
        this.ipAddress = ipAddress;
        this.userAgent = userAgent;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Static factory methods
    public static AuditLog success(Long userId, Action action, String ipAddress, String userAgent) {
        AuditLog log = new AuditLog(userId, action, ipAddress, userAgent);
        log.setSuccess(true);
        return log;
    }

    public static AuditLog failure(Long userId, Action action, String ipAddress, String userAgent, String error) {
        AuditLog log = new AuditLog(userId, action, ipAddress, userAgent);
        log.setSuccess(false);
        log.setErrorMessage(error);
        return log;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(Long targetUserId) {
        this.targetUserId = targetUserId;
    }

    public Action getAction() {
        return action;
    }

    public void setAction(Action action) {
        this.action = action;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
