package com.nozie.identityservice.entity;

import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {

    public enum Action {
        LOGIN, LOGIN_FAILED, LOGOUT, LOGOUT_ALL,
        REGISTER, PASSWORD_CHANGE, PASSWORD_RESET,
        TOKEN_REFRESH, TOKEN_REVOKE,
        ROLE_ASSIGN, ROLE_REVOKE,
        USER_LOCK, USER_UNLOCK, USER_DISABLE,
        PERMISSION_GRANT, PERMISSION_REVOKE,
        PROFILE_UPDATE
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
    @Builder.Default
    private boolean success = true;

    @Column(name = "error_message")
    private String errorMessage;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

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
}
