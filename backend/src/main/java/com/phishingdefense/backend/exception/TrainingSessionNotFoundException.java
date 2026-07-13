package com.phishingdefense.backend.exception;

public class TrainingSessionNotFoundException extends RuntimeException {

    public TrainingSessionNotFoundException(String sessionId) {
        super("훈련 세션을 찾을 수 없습니다: " + sessionId);
    }
}
