package com.nozie.identityservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.identityservice.entity.*;
import com.nozie.identityservice.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserSessionRepository userSessionRepository;
    private final UserProfileRepository userProfileRepository;
    private final AuditService auditService;

    public UserService(UserRepository userRepository,
            RoleRepository roleRepository,
            RefreshTokenRepository refreshTokenRepository,
            UserSessionRepository userSessionRepository,
            UserProfileRepository userProfileRepository,
            AuditService auditService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.userSessionRepository = userSessionRepository;
        this.userProfileRepository = userProfileRepository;
        this.auditService = auditService;
    }

    @Transactional(readOnly = true)
    public Page<User> getAllUsers(Pageable pageable) {
        return userRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("User not found"));
    }

    public User updateUserStatus(Long userId, User.Status status, Long adminId, String ipAddress, String userAgent) {
        User user = getUserById(userId);
        User.Status oldStatus = user.getStatus();
        user.setStatus(status);

        if (status == User.Status.LOCKED) {
            user.setLockedUntil(null); // Manual lock has no expiry
        }

        User savedUser = userRepository.save(user);

        AuditLog.Action action = status == User.Status.LOCKED ? AuditLog.Action.USER_LOCK
                : status == User.Status.DISABLED ? AuditLog.Action.USER_DISABLE : AuditLog.Action.USER_UNLOCK;

        auditService.logAdminAction(adminId, userId, action, ipAddress, userAgent,
                "Status changed from " + oldStatus + " to " + status);

        log.info("User {} status changed to {} by admin {}", userId, status, adminId);
        return savedUser;
    }

    public User addRoleToUser(Long userId, Long roleId, Long adminId, String ipAddress, String userAgent) {
        User user = getUserById(userId);
        Role role = roleRepository.findById(roleId)
                .orElseThrow(() -> new BadRequestException("Role not found"));

        user.addRole(role);
        User savedUser = userRepository.save(user);

        auditService.logAdminAction(adminId, userId, AuditLog.Action.ROLE_ASSIGN, ipAddress, userAgent,
                "Assigned role: " + role.getName());

        log.info("Role {} assigned to user {} by admin {}", role.getName(), userId, adminId);
        return savedUser;
    }

    public User removeRoleFromUser(Long userId, Long roleId, Long adminId, String ipAddress, String userAgent) {
        User user = getUserById(userId);
        Role role = roleRepository.findById(roleId)
                .orElseThrow(() -> new BadRequestException("Role not found"));

        // Prevent removing the last role
        if (user.getRoles().size() <= 1) {
            throw new BadRequestException("User must have at least one role");
        }

        user.removeRole(role);
        User savedUser = userRepository.save(user);

        auditService.logAdminAction(adminId, userId, AuditLog.Action.ROLE_REVOKE, ipAddress, userAgent,
                "Revoked role: " + role.getName());

        log.info("Role {} removed from user {} by admin {}", role.getName(), userId, adminId);
        return savedUser;
    }

    public void forceLogoutUser(Long userId, Long adminId, String ipAddress, String userAgent) {
        // Revoke all refresh tokens
        refreshTokenRepository.revokeAllByUserId(userId, java.time.LocalDateTime.now(), "Force logout by admin");

        // Deactivate all sessions
        userSessionRepository.deactivateAllByUserId(userId);

        auditService.logAdminAction(adminId, userId, AuditLog.Action.LOGOUT_ALL, ipAddress, userAgent,
                "Force logout by admin");

        log.info("User {} force logged out by admin {}", userId, adminId);
    }

    @Transactional(readOnly = true)
    public List<UserSession> getUserSessions(Long userId) {
        return userSessionRepository.findByUserIdAndIsActiveTrue(userId);
    }

    @Transactional(readOnly = true)
    public Set<String> getUserRoleNames(Long userId) {
        User user = getUserById(userId);
        return user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());
    }

    @Transactional(readOnly = true)
    public Set<String> getUserPermissionNames(Long userId) {
        User user = getUserById(userId);
        return user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(Permission::getName)
                .collect(Collectors.toSet());
    }

    @Transactional(readOnly = true)
    public boolean hasRole(Long userId, String roleName) {
        return getUserRoleNames(userId).contains(roleName);
    }

    @Transactional(readOnly = true)
    public boolean hasPermission(Long userId, String permissionName) {
        return getUserPermissionNames(userId).contains(permissionName);
    }

    public User updateProfile(Long userId, com.nozie.identityservice.dto.request.UpdateProfileRequest request,
            String ipAddress,
            String userAgent) {
        log.info("Updating profile for user: {}", userId);
        User user = getUserById(userId);

        UserProfile profile = user.getProfile();
        if (profile == null) {
            profile = UserProfile.builder().user(user).userId(userId).build();
        }

        if (request.getFullName() != null)
            profile.setFullName(request.getFullName());
        if (request.getDateOfBirth() != null)
            profile.setDateOfBirth(request.getDateOfBirth());
        if (request.getCountry() != null)
            profile.setCountry(request.getCountry());
        if (request.getGender() != null)
            profile.setGender(request.getGender());
        if (request.getAge() != null)
            profile.setAge(request.getAge());
        if (request.getAvatarUrl() != null)
            profile.setAvatarUrl(request.getAvatarUrl());
        if (request.getGenres() != null)
            profile.setGenres(new java.util.HashSet<>(request.getGenres()));

        if (request.getPhone() != null) {
            user.setPhoneNumber(request.getPhone());
        }

        userProfileRepository.save(profile);
        User savedUser = userRepository.save(user);

        auditService.logSuccess(userId, AuditLog.Action.PROFILE_UPDATE, ipAddress, userAgent);

        return savedUser;
    }
}
