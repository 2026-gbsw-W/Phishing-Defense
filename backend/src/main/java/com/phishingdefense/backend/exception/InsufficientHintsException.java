package com.phishingdefense.backend.exception;

public class InsufficientHintsException extends RuntimeException {

    public InsufficientHintsException() {
        super("사용 가능한 힌트가 없습니다.");
    }
}
