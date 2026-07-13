package com.phishingdefense.backend.exception;

public class ScenarioRecordAlreadyCompletedException extends RuntimeException {

    public ScenarioRecordAlreadyCompletedException(Long recordId) {
        super("이미 완료된 플레이입니다: " + recordId);
    }
}
