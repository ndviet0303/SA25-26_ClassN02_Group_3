package com.nozie.identityservice.service;

import com.nozie.common.exception.BadRequestException;
import com.nozie.identityservice.entity.Permission;
import com.nozie.identityservice.entity.Role;
import com.nozie.identityservice.repository.PermissionRepository;
import com.nozie.identityservice.repository.RoleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

@Service
@Transactional
public class RoleService {

    private static final Logger log = LoggerFactory.getLogger(RoleService.class);

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;

    public RoleService(RoleRepository roleRepository, PermissionRepository permissionRepository) {
        this.roleRepository = roleRepository;
        this.permissionRepository = permissionRepository;
    }

    public Role createRole(String name, String description) {
        log.info("Creating role: {}", name);

        if (roleRepository.existsByName(name)) {
            throw new BadRequestException("Role '" + name + "' already exists");
        }

        Role role = new Role(name.toUpperCase(), description);
        return roleRepository.save(role);
    }

    public Role updateRole(Long roleId, String name, String description) {
        Role role = getRoleById(roleId);

        if (name != null && !name.equals(role.getName())) {
            if (roleRepository.existsByName(name)) {
                throw new BadRequestException("Role '" + name + "' already exists");
            }
            role.setName(name.toUpperCase());
        }

        if (description != null) {
            role.setDescription(description);
        }

        return roleRepository.save(role);
    }

    public void deleteRole(Long roleId) {
        Role role = getRoleById(roleId);

        // Prevent deleting system roles
        if (role.getName().equals("ADMIN") || role.getName().equals("USER")) {
            throw new BadRequestException("Cannot delete system role: " + role.getName());
        }

        roleRepository.delete(role);
        log.info("Deleted role: {}", role.getName());
    }

    @Transactional(readOnly = true)
    public Role getRoleById(Long id) {
        return roleRepository.findById(id)
                .orElseThrow(() -> new BadRequestException("Role not found"));
    }

    @Transactional(readOnly = true)
    public Role getRoleByName(String name) {
        return roleRepository.findByName(name)
                .orElseThrow(() -> new BadRequestException("Role not found: " + name));
    }

    @Transactional(readOnly = true)
    public List<Role> getAllRoles() {
        return roleRepository.findAll();
    }

    public Role addPermissionToRole(Long roleId, Long permissionId) {
        Role role = getRoleById(roleId);
        Permission permission = permissionRepository.findById(permissionId)
                .orElseThrow(() -> new BadRequestException("Permission not found"));

        role.addPermission(permission);
        return roleRepository.save(role);
    }

    public Role removePermissionFromRole(Long roleId, Long permissionId) {
        Role role = getRoleById(roleId);
        Permission permission = permissionRepository.findById(permissionId)
                .orElseThrow(() -> new BadRequestException("Permission not found"));

        role.removePermission(permission);
        return roleRepository.save(role);
    }

    public Role setPermissions(Long roleId, Set<Long> permissionIds) {
        Role role = getRoleById(roleId);

        List<Permission> permissions = permissionRepository.findAllById(permissionIds);
        role.setPermissions(new java.util.HashSet<>(permissions));

        return roleRepository.save(role);
    }

    /**
     * Initialize default roles if not exist
     */
    public void initializeDefaultRoles() {
        if (!roleRepository.existsByName("ADMIN")) {
            createRole("ADMIN", "Administrator with full access");
            log.info("Created default ADMIN role");
        }
        if (!roleRepository.existsByName("USER")) {
            createRole("USER", "Standard user role");
            log.info("Created default USER role");
        }
        if (!roleRepository.existsByName("MODERATOR")) {
            createRole("MODERATOR", "Moderator with limited admin access");
            log.info("Created default MODERATOR role");
        }
    }
}
