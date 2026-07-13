package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.UserAchievement;
import java.time.LocalDateTime;

public record UserAchievementResponse(
        Long userAchievementId,
        Integer achievementId,
        LocalDateTime unlockedAt
) {
    public static UserAchievementResponse from(UserAchievement userAchievement) {
        return new UserAchievementResponse(
                userAchievement.getUserAchievementId(),
                userAchievement.getAchievementId(),
                userAchievement.getUnlockedAt()
        );
    }
}
