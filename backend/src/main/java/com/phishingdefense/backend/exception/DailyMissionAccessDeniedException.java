package com.phishingdefense.backend.exception;

public class DailyMissionAccessDeniedException extends RuntimeException {

    public DailyMissionAccessDeniedException() {
        super("본인의 미션만 완료할 수 있습니다.");
    }
}
