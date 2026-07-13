package com.phishingdefense.backend.exception;

public class AchievementNotFoundException extends RuntimeException {

    public AchievementNotFoundException(Integer achievementId) {
        super("업적을 찾을 수 없습니다: " + achievementId);
    }
}
