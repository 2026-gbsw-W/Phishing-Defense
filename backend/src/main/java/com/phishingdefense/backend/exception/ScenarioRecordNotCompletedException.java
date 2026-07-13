package com.phishingdefense.backend.exception;

public class ScenarioRecordNotCompletedException extends RuntimeException {

    public ScenarioRecordNotCompletedException(Long recordId) {
        super("완료되지 않은 플레이 기록으로는 미션을 완료할 수 없습니다: " + recordId);
    }
}
