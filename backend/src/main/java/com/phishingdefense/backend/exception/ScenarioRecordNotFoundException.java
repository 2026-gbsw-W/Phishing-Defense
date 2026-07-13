package com.phishingdefense.backend.exception;

public class ScenarioRecordNotFoundException extends RuntimeException {

    public ScenarioRecordNotFoundException(Long recordId) {
        super("플레이 기록을 찾을 수 없습니다: " + recordId);
    }
}
