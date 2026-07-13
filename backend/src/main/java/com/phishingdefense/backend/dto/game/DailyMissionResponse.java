package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.DailyMission;
import java.time.LocalDateTime;

public record DailyMissionResponse(
        Long missionId,
        String missionType,
        String missionDescription,
        String recommendationReason,
        Boolean completed,
        LocalDateTime completedAt,
        Integer rewardXp
) {
    public static DailyMissionResponse from(DailyMission mission) {
        return new DailyMissionResponse(
                mission.getMissionId(),
                mission.getMissionType(),
                mission.getMissionDescription(),
                mission.getRecommendationReason(),
                mission.getCompleted(),
                mission.getCompletedAt(),
                mission.getRewardXp()
        );
    }
}
