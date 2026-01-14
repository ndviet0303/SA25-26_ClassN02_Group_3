package com.nozie.identityservice.service;

import com.nozie.identityservice.entity.AuditLog;
import com.nozie.identityservice.repository.AuditLogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class AuditService {

    private static final Logger log = LoggerFactory.getLogger(AuditService.class);

    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    public AuditLog logSuccess(Long userId, AuditLog.Action action, String ipAddress, String userAgent) {
        AuditLog auditLog = AuditLog.success(userId, action, ipAddress, userAgent);
        return auditLogRepository.save(auditLog);
    }

    public AuditLog logSuccess(Long userId, AuditLog.Action action, String ipAddress, String userAgent,
            String details) {
        AuditLog auditLog = AuditLog.success(userId, action, ipAddress, userAgent);
        auditLog.setDetails(details);
        return auditLogRepository.save(auditLog);
    }

    public AuditLog logFailure(Long userId, AuditLog.Action action, String ipAddress, String userAgent, String error) {
        AuditLog auditLog = AuditLog.failure(userId, action, ipAddress, userAgent, error);
        return auditLogRepository.save(auditLog);
    }

    public AuditLog logAdminAction(Long adminId, Long targetUserId, AuditLog.Action action,
            String ipAddress, String userAgent, String details) {
        AuditLog auditLog = new AuditLog(adminId, action, ipAddress, userAgent);
        auditLog.setTargetUserId(targetUserId);
        auditLog.setDetails(details);
        return auditLogRepository.save(auditLog);
    }

    public Page<AuditLog> getAuditLogs(Pageable pageable) {
        return auditLogRepository.findAllByOrderByCreatedAtDesc(pageable);
    }

    public Page<AuditLog> getAuditLogsByUser(Long userId, Pageable pageable) {
        return auditLogRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    public Page<AuditLog> getAuditLogsByAction(AuditLog.Action action, Pageable pageable) {
        return auditLogRepository.findByActionOrderByCreatedAtDesc(action, pageable);
    }
}
