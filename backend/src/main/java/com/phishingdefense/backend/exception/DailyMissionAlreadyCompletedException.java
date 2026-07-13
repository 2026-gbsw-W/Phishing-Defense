package com.phishingdefense.backend.exception;

public class DailyMissionAlreadyCompletedException extends RuntimeException {

    public DailyMissionAlreadyCompletedException() {
        super("이미 완료한 미션입니다.");
    }
}
