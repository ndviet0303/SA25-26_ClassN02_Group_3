package com.nozie.identityservice.repository;

import com.nozie.identityservice.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PermissionRepository extends JpaRepository<Permission, Long> {

    Optional<Permission> findByName(String name);

    boolean existsByName(String name);

    List<Permission> findByResource(String resource);

    List<Permission> findByAction(String action);
}
