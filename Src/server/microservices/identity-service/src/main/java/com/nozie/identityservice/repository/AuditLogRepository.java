package com.nozie.identityservice.repository;

import com.nozie.identityservice.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    Page<AuditLog> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    Page<AuditLog> findByActionOrderByCreatedAtDesc(AuditLog.Action action, Pageable pageable);

    List<AuditLog> findByUserIdAndCreatedAtAfter(Long userId, LocalDateTime after);

    List<AuditLog> findByIpAddressOrderByCreatedAtDesc(String ipAddress);

    Page<AuditLog> findAllByOrderByCreatedAtDesc(Pageable pageable);

    long countByUserIdAndActionAndCreatedAtAfter(Long userId, AuditLog.Action action, LocalDateTime after);
}
