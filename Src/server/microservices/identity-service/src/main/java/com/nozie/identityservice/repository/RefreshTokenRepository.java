package com.nozie.identityservice.repository;

import com.nozie.identityservice.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    Optional<RefreshToken> findByToken(String token);

    List<RefreshToken> findByUserIdAndRevokedAtIsNull(Long userId);

    List<RefreshToken> findByUserId(Long userId);

    @Modifying
    @Query("UPDATE RefreshToken rt SET rt.revokedAt = :revokedAt, rt.revokedReason = :reason WHERE rt.userId = :userId AND rt.revokedAt IS NULL")
    int revokeAllByUserId(@Param("userId") Long userId, @Param("revokedAt") LocalDateTime revokedAt,
            @Param("reason") String reason);

    @Modifying
    @Query("DELETE FROM RefreshToken rt WHERE rt.expiresAt < :now")
    int deleteExpiredTokens(@Param("now") LocalDateTime now);

    long countByUserIdAndRevokedAtIsNull(Long userId);
}
