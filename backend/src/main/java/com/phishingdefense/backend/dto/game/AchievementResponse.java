package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Achievement;

public record AchievementResponse(
        Integer achievementId,
        String category,
        String name,
        String description,
        String iconUrl,
        Integer xpReward,
        Integer coinReward
) {
    public static AchievementResponse from(Achievement achievement) {
        return new AchievementResponse(
                achievement.getAchievementId(),
                achievement.getCategory(),
                achievement.getName(),
                achievement.getDescription(),
                achievement.getIconUrl(),
                achievement.getXpReward(),
                achievement.getCoinReward()
        );
    }
}
