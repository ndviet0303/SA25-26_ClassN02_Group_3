package com.nozie.identityservice.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.identityservice.entity.*;
import com.nozie.identityservice.service.*;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private static final Logger log = LoggerFactory.getLogger(AdminController.class);

    private final UserService userService;
    private final RoleService roleService;
    private final PermissionService permissionService;
    private final AuditService auditService;
    private final TokenService tokenService;

    public AdminController(UserService userService,
            RoleService roleService,
            PermissionService permissionService,
            AuditService auditService,
            TokenService tokenService) {
        this.userService = userService;
        this.roleService = roleService;
        this.permissionService = permissionService;
        this.auditService = auditService;
        this.tokenService = tokenService;
    }

    // ========== USER MANAGEMENT ==========

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.info("GET /api/admin/users");

        Pageable pageable = PageRequest.of(page, size);
        Page<User> users = userService.getAllUsers(pageable);

        List<Map<String, Object>> userList = users.getContent().stream()
                .map(this::mapUserToResponse)
                .collect(Collectors.toList());

        Map<String, Object> response = Map.of(
                "users", userList,
                "currentPage", users.getNumber(),
                "totalPages", users.getTotalPages(),
                "totalElements", users.getTotalElements());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserById(@PathVariable Long id) {
        log.info("GET /api/admin/users/{}", id);
        User user = userService.getUserById(id);
        return ResponseEntity.ok(ApiResponse.success(mapUserToResponse(user)));
    }

    @PutMapping("/users/{id}/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateUserStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request,
            @RequestHeader("Authorization") String authHeader,
            HttpServletRequest httpRequest) {
        log.info("PUT /api/admin/users/{}/status", id);

        String token = authHeader.substring(7);
        Long adminId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        User.Status status = User.Status.valueOf(request.get("status").toUpperCase());
        User user = userService.updateUserStatus(id, status, adminId, ipAddress, userAgent);

        return ResponseEntity.ok(ApiResponse.success("User status updated", mapUserToResponse(user)));
    }

    @DeleteMapping("/users/{id}/sessions")
    public ResponseEntity<ApiResponse<Void>> forceLogoutUser(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader,
            HttpServletRequest httpRequest) {
        log.info("DELETE /api/admin/users/{}/sessions", id);

        String token = authHeader.substring(7);
        Long adminId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        userService.forceLogoutUser(id, adminId, ipAddress, userAgent);

        return ResponseEntity.ok(ApiResponse.success("User logged out from all sessions", null));
    }

    @GetMapping("/users/{id}/sessions")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getUserSessions(@PathVariable Long id) {
        log.info("GET /api/admin/users/{}/sessions", id);

        List<UserSession> sessions = userService.getUserSessions(id);

        List<Map<String, Object>> sessionList = sessions.stream()
                .map(session -> Map.<String, Object>of(
                        "id", session.getId(),
                        "deviceInfo", session.getDeviceInfo() != null ? session.getDeviceInfo() : "",
                        "ipAddress", session.getIpAddress() != null ? session.getIpAddress() : "",
                        "lastAccessAt", session.getLastAccessAt().toString(),
                        "createdAt", session.getCreatedAt().toString()))
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(sessionList));
    }

    // ========== ROLE MANAGEMENT ==========

    @GetMapping("/roles")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllRoles() {
        log.info("GET /api/admin/roles");

        List<Role> roles = roleService.getAllRoles();

        List<Map<String, Object>> roleList = roles.stream()
                .map(this::mapRoleToResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(roleList));
    }

    @PostMapping("/roles")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createRole(@RequestBody Map<String, String> request) {
        log.info("POST /api/admin/roles");

        String name = request.get("name");
        String description = request.get("description");

        Role role = roleService.createRole(name, description);

        return new ResponseEntity<>(
                ApiResponse.success("Role created", mapRoleToResponse(role)),
                HttpStatus.CREATED);
    }

    @PutMapping("/roles/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updateRole(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        log.info("PUT /api/admin/roles/{}", id);

        String name = request.get("name");
        String description = request.get("description");

        Role role = roleService.updateRole(id, name, description);

        return ResponseEntity.ok(ApiResponse.success("Role updated", mapRoleToResponse(role)));
    }

    @DeleteMapping("/roles/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteRole(@PathVariable Long id) {
        log.info("DELETE /api/admin/roles/{}", id);
        roleService.deleteRole(id);
        return ResponseEntity.ok(ApiResponse.success("Role deleted", null));
    }

    @PutMapping("/roles/{id}/permissions")
    public ResponseEntity<ApiResponse<Map<String, Object>>> setRolePermissions(
            @PathVariable Long id,
            @RequestBody Map<String, List<Long>> request) {
        log.info("PUT /api/admin/roles/{}/permissions", id);

        Set<Long> permissionIds = new java.util.HashSet<>(request.get("permissionIds"));
        Role role = roleService.setPermissions(id, permissionIds);

        return ResponseEntity.ok(ApiResponse.success("Role permissions updated", mapRoleToResponse(role)));
    }

    @PostMapping("/users/{userId}/roles")
    public ResponseEntity<ApiResponse<Map<String, Object>>> addRoleToUser(
            @PathVariable Long userId,
            @RequestBody Map<String, Long> request,
            @RequestHeader("Authorization") String authHeader,
            HttpServletRequest httpRequest) {
        log.info("POST /api/admin/users/{}/roles", userId);

        String token = authHeader.substring(7);
        Long adminId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        Long roleId = request.get("roleId");
        User user = userService.addRoleToUser(userId, roleId, adminId, ipAddress, userAgent);

        return ResponseEntity.ok(ApiResponse.success("Role assigned", mapUserToResponse(user)));
    }

    @DeleteMapping("/users/{userId}/roles/{roleId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> removeRoleFromUser(
            @PathVariable Long userId,
            @PathVariable Long roleId,
            @RequestHeader("Authorization") String authHeader,
            HttpServletRequest httpRequest) {
        log.info("DELETE /api/admin/users/{}/roles/{}", userId, roleId);

        String token = authHeader.substring(7);
        Long adminId = tokenService.getUserIdFromToken(token);
        String ipAddress = getClientIP(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");

        User user = userService.removeRoleFromUser(userId, roleId, adminId, ipAddress, userAgent);

        return ResponseEntity.ok(ApiResponse.success("Role removed", mapUserToResponse(user)));
    }

    // ========== PERMISSION MANAGEMENT ==========

    @GetMapping("/permissions")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllPermissions() {
        log.info("GET /api/admin/permissions");

        List<Permission> permissions = permissionService.getAllPermissions();

        List<Map<String, Object>> permissionList = permissions.stream()
                .map(this::mapPermissionToResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(permissionList));
    }

    @PostMapping("/permissions")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createPermission(
            @RequestBody Map<String, String> request) {
        log.info("POST /api/admin/permissions");

        Permission permission = permissionService.createPermission(
                request.get("name"),
                request.get("description"),
                request.get("resource"),
                request.get("action"));

        return new ResponseEntity<>(
                ApiResponse.success("Permission created", mapPermissionToResponse(permission)),
                HttpStatus.CREATED);
    }

    @DeleteMapping("/permissions/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePermission(@PathVariable Long id) {
        log.info("DELETE /api/admin/permissions/{}", id);
        permissionService.deletePermission(id);
        return ResponseEntity.ok(ApiResponse.success("Permission deleted", null));
    }

    // ========== AUDIT LOGS ==========

    @GetMapping("/audit-logs")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAuditLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        log.info("GET /api/admin/audit-logs");

        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> logs = auditService.getAuditLogs(pageable);

        List<Map<String, Object>> logList = logs.getContent().stream()
                .map(this::mapAuditLogToResponse)
                .collect(Collectors.toList());

        Map<String, Object> response = Map.of(
                "logs", logList,
                "currentPage", logs.getNumber(),
                "totalPages", logs.getTotalPages(),
                "totalElements", logs.getTotalElements());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/audit-logs/user/{userId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAuditLogsByUser(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        log.info("GET /api/admin/audit-logs/user/{}", userId);

        Pageable pageable = PageRequest.of(page, size);
        Page<AuditLog> logs = auditService.getAuditLogsByUser(userId, pageable);

        List<Map<String, Object>> logList = logs.getContent().stream()
                .map(this::mapAuditLogToResponse)
                .collect(Collectors.toList());

        Map<String, Object> response = Map.of(
                "logs", logList,
                "currentPage", logs.getNumber(),
                "totalPages", logs.getTotalPages(),
                "totalElements", logs.getTotalElements());

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    // ========== HELPER METHODS ==========

    private Map<String, Object> mapUserToResponse(User user) {
        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());

        Set<String> permissions = user.getRoles().stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(Permission::getName)
                .collect(Collectors.toSet());

        return Map.of(
                "id", user.getId(),
                "username", user.getUsername(),
                "email", user.getEmail() != null ? user.getEmail() : "",
                "phoneNumber", user.getPhoneNumber() != null ? user.getPhoneNumber() : "",
                "status", user.getStatus().name(),
                "roles", roles,
                "permissions", permissions,
                "failedLoginAttempts", user.getFailedLoginAttempts(),
                "lastLoginAt", user.getLastLoginAt() != null ? user.getLastLoginAt().toString() : "",
                "createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : "");
    }

    private Map<String, Object> mapRoleToResponse(Role role) {
        Set<String> permissions = role.getPermissions().stream()
                .map(Permission::getName)
                .collect(Collectors.toSet());

        return Map.of(
                "id", role.getId(),
                "name", role.getName(),
                "description", role.getDescription() != null ? role.getDescription() : "",
                "permissions", permissions,
                "createdAt", role.getCreatedAt() != null ? role.getCreatedAt().toString() : "");
    }

    private Map<String, Object> mapPermissionToResponse(Permission permission) {
        return Map.of(
                "id", permission.getId(),
                "name", permission.getName(),
                "description", permission.getDescription() != null ? permission.getDescription() : "",
                "resource", permission.getResource() != null ? permission.getResource() : "",
                "action", permission.getAction() != null ? permission.getAction() : "",
                "createdAt", permission.getCreatedAt() != null ? permission.getCreatedAt().toString() : "");
    }

    private Map<String, Object> mapAuditLogToResponse(AuditLog log) {
        return Map.of(
                "id", log.getId(),
                "userId", log.getUserId() != null ? log.getUserId() : 0,
                "targetUserId", log.getTargetUserId() != null ? log.getTargetUserId() : 0,
                "action", log.getAction().name(),
                "ipAddress", log.getIpAddress() != null ? log.getIpAddress() : "",
                "success", log.isSuccess(),
                "errorMessage", log.getErrorMessage() != null ? log.getErrorMessage() : "",
                "details", log.getDetails() != null ? log.getDetails() : "",
                "createdAt", log.getCreatedAt().toString());
    }

    private String getClientIP(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
