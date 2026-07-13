package com.phishingdefense.backend.exception;

public class TrainingResultNotFoundException extends RuntimeException {

    public TrainingResultNotFoundException(String sessionId) {
        super("훈련 결과를 찾을 수 없습니다: " + sessionId);
    }
}
