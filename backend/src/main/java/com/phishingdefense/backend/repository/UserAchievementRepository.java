package com.phishingdefense.backend.repository;

import com.phishingdefense.backend.entity.UserAchievement;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAchievementRepository extends JpaRepository<UserAchievement, Long> {

    List<UserAchievement> findByUserId(Long userId);

    Optional<UserAchievement> findByUserIdAndAchievementId(Long userId, Integer achievementId);

    boolean existsByUserIdAndAchievementId(Long userId, Integer achievementId);
}
