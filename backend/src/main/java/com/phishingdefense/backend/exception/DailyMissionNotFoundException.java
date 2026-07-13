package com.phishingdefense.backend.exception;

public class DailyMissionNotFoundException extends RuntimeException {

    public DailyMissionNotFoundException(Long missionId) {
        super("일일 미션을 찾을 수 없습니다: " + missionId);
    }
}
