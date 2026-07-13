package com.phishingdefense.backend.dto.user;

import java.time.LocalDateTime;

public record UserAchievementStatusResponse(
        Integer achievementId,
        String name,
        String description,
        String iconUrl,
        boolean unlocked,
        LocalDateTime unlockedAt
) {
}
