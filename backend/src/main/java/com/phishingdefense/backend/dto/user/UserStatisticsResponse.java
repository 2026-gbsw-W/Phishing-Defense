package com.phishingdefense.backend.dto.user;

import java.util.Map;

public record UserStatisticsResponse(
        long totalPlays,
        double averageStar,
        Map<String, Double> accuracyByType,
        String mostUsedHintType
) {
}
