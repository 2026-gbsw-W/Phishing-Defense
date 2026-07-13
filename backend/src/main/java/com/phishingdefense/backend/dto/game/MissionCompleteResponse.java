package com.phishingdefense.backend.dto.game;

public record MissionCompleteResponse(
        boolean success,
        Integer rewardXp
) {
}
