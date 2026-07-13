package com.phishingdefense.backend.exception;

public class ScenarioRecordAccessDeniedException extends RuntimeException {

    public ScenarioRecordAccessDeniedException() {
        super("본인의 플레이 기록만 조회할 수 있습니다.");
    }
}
