package com.phishingdefense.backend.dto.game;

import java.time.LocalDate;
import java.util.List;

public record AttendanceStatusResponse(
        Integer consecutiveDays,
        Boolean currentStreak,
        NextRewardResponse nextReward,
        List<LocalDate> calendar
) {
}
