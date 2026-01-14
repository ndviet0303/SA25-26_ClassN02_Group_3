package com.nozie.identityservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.identityservice.entity.Permission;
import com.nozie.identityservice.repository.PermissionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class PermissionService {

    private static final Logger log = LoggerFactory.getLogger(PermissionService.class);

    private final PermissionRepository permissionRepository;

    public PermissionService(PermissionRepository permissionRepository) {
        this.permissionRepository = permissionRepository;
    }

    public Permission createPermission(String name, String description, String resource, String action) {
        log.info("Creating permission: {}", name);

        if (permissionRepository.existsByName(name)) {
            throw new BadRequestException("Permission '" + name + "' already exists");
        }

        Permission permission = new Permission(name, description, resource, action);
        return permissionRepository.save(permission);
    }

    public Permission updatePermission(Long permissionId, String name, String description,
            String resource, String action) {
        Permission permission = getPermissionById(permissionId);

        if (name != null && !name.equals(permission.getName())) {
            if (permissionRepository.existsByName(name)) {
                throw new BadRequestException("Permission '" + name + "' already exists");
            }
            permission.setName(name);
        }

        if (description != null)
            permission.setDescription(description);
        if (resource != null)
            permission.setResource(resource);
        if (action != null)
            permission.setAction(action);

        return permissionRepository.save(permission);
    }

    public void deletePermission(Long permissionId) {
        Permission permission = getPermissionById(permissionId);
        permissionRepository.delete(permission);
        log.info("Deleted permission: {}", permission.getName());
    }

    @Transactional(readOnly = true)
    public Permission getPermissionById(Long id) {
        return permissionRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Permission not found"));
    }

    @Transactional(readOnly = true)
    public Permission getPermissionByName(String name) {
        return permissionRepository.findByName(name)
                .orElseThrow(() -> new BadRequestException("Permission not found: " + name));
    }

    @Transactional(readOnly = true)
    public List<Permission> getAllPermissions() {
        return permissionRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Permission> getPermissionsByResource(String resource) {
        return permissionRepository.findByResource(resource);
    }

    /**
     * Initialize default permissions if not exist
     */
    public void initializeDefaultPermissions() {
        createIfNotExists("movie:read", "View movies", "movie", "read");
        createIfNotExists("movie:write", "Create/update movies", "movie", "write");
        createIfNotExists("movie:delete", "Delete movies", "movie", "delete");

        createIfNotExists("customer:read", "View customers", "customer", "read");
        createIfNotExists("customer:write", "Create/update customers", "customer", "write");
        createIfNotExists("customer:delete", "Delete customers", "customer", "delete");

        createIfNotExists("payment:read", "View payments", "payment", "read");
        createIfNotExists("payment:write", "Create payments", "payment", "write");

        createIfNotExists("notification:read", "View notifications", "notification", "read");
        createIfNotExists("notification:write", "Send notifications", "notification", "write");

        createIfNotExists("user:read", "View users", "user", "read");
        createIfNotExists("user:write", "Manage users", "user", "write");
        createIfNotExists("user:admin", "Full admin access", "user", "admin");

        log.info("Default permissions initialized");
    }

    private void createIfNotExists(String name, String description, String resource, String action) {
        if (!permissionRepository.existsByName(name)) {
            Permission permission = new Permission(name, description, resource, action);
            permissionRepository.save(permission);
            log.info("Created permission: {}", name);
        }
    }
}
