package com.nozie.identityservice.config;

import com.nozie.identityservice.entity.Role;
import com.nozie.identityservice.entity.User;
import com.nozie.identityservice.repository.PermissionRepository;
import com.nozie.identityservice.repository.RoleRepository;
import com.nozie.identityservice.repository.UserRepository;
import com.nozie.identityservice.service.PermissionService;
import com.nozie.identityservice.service.RoleService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

@Configuration
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final PermissionService permissionService;
    private final RoleService roleService;
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(PermissionService permissionService,
            RoleService roleService,
            RoleRepository roleRepository,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder) {
        this.permissionService = permissionService;
        this.roleService = roleService;
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        log.info("Starting data initialization...");

        // 1. Initialize Permissions
        permissionService.initializeDefaultPermissions();

        // 2. Initialize Roles
        roleService.initializeDefaultRoles();

        // 3. Initialize Admin User
        initializeAdminUser();

        log.info("Data initialization completed.");
    }

    private void initializeAdminUser() {
        if (!userRepository.existsByUsername("admin")) {
            log.info("Creating default admin user...");

            User admin = new User();
            admin.setUsername("admin");
            admin.setEmail("admin@nozie.com");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setStatus(User.Status.ACTIVE);

            // Assign ADMIN role
            Role adminRole = roleRepository.findByName("ADMIN")
                    .orElseThrow(() -> new RuntimeException("ADMIN role not found after initialization"));

            admin.addRole(adminRole);

            userRepository.save(admin);
            log.info("Default admin user created: admin / admin123");
        } else {
            log.info("Admin user already exists.");
        }
    }
}
