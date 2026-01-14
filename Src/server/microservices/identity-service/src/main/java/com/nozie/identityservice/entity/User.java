package com.nozie.identityservice.entity;

import lombok.*;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    public enum Status {
        ACTIVE, LOCKED, DISABLED
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    @Column(unique = true, nullable = false)
    private String username;

    @Email(message = "Invalid email format")
    @Column(unique = true)
    private String email;

    @Column(name = "phone_number")
    private String phoneNumber;

    @NotBlank(message = "Password is required")
    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Status status = Status.ACTIVE;

    @Column(name = "failed_login_attempts")
    @Builder.Default
    private int failedLoginAttempts = 0;

    @Column(name = "locked_until")
    private LocalDateTime lockedUntil;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    @Column(name = "last_login_ip")
    private String lastLoginIp;

    @Column(name = "password_changed_at")
    private LocalDateTime passwordChangedAt;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"), inverseJoinColumns = @JoinColumn(name = "role_id"))
    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private UserProfile profile;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public User(String username, String password) {
        this.username = username;
        this.password = password;
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Helper methods
    public boolean isAccountLocked() {
        if (status == Status.LOCKED && lockedUntil != null) {
            if (LocalDateTime.now().isAfter(lockedUntil)) {
                // Auto unlock after lock period
                status = Status.ACTIVE;
                failedLoginAttempts = 0;
                lockedUntil = null;
                return false;
            }
            return true;
        }
        return status == Status.LOCKED;
    }

    public void incrementFailedAttempts() {
        this.failedLoginAttempts++;
        if (this.failedLoginAttempts >= 5) {
            this.status = Status.LOCKED;
            this.lockedUntil = LocalDateTime.now().plusMinutes(15);
        }
    }

    public void resetFailedAttempts() {
        this.failedLoginAttempts = 0;
        this.status = Status.ACTIVE;
        this.lockedUntil = null;
    }

    public void recordLogin(String ipAddress) {
        this.lastLoginAt = LocalDateTime.now();
        this.lastLoginIp = ipAddress;
        resetFailedAttempts();
    }

    public void addRole(Role role) {
        if (this.roles == null) {
            this.roles = new HashSet<>();
        }
        this.roles.add(role);
    }

    public void removeRole(Role role) {
        if (this.roles != null) {
            this.roles.remove(role);
        }
    }
}
