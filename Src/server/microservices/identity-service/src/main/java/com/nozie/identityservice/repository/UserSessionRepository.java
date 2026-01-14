package com.nozie.identityservice.repository;

import com.nozie.identityservice.entity.UserSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserSessionRepository extends JpaRepository<UserSession, Long> {

    List<UserSession> findByUserIdAndIsActiveTrue(Long userId);

    Optional<UserSession> findByRefreshTokenId(Long refreshTokenId);

    @Modifying
    @Query("UPDATE UserSession us SET us.isActive = false WHERE us.userId = :userId")
    int deactivateAllByUserId(@Param("userId") Long userId);

    long countByUserIdAndIsActiveTrue(Long userId);
}
