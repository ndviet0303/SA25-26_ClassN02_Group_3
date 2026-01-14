package com.nozie.identityservice.entity;

import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "refresh_token_id")
    private Long refreshTokenId;

    @Column(name = "device_info")
    private String deviceInfo;

    @Column(name = "device_type")
    private String deviceType; // MOBILE, DESKTOP, TABLET, UNKNOWN

    @Column(name = "browser")
    private String browser;

    @Column(name = "os")
    private String os;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "location")
    private String location;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(name = "is_active")
    @Builder.Default
    private boolean isActive = true;

    @Column(name = "last_access_at")
    private LocalDateTime lastAccessAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public UserSession(Long userId, Long refreshTokenId, String deviceInfo, String ipAddress) {
        this.userId = userId;
        this.refreshTokenId = refreshTokenId;
        this.deviceInfo = deviceInfo;
        this.ipAddress = ipAddress;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        lastAccessAt = LocalDateTime.now();
    }

    public void updateLastAccess() {
        this.lastAccessAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.isActive = false;
    }
}
