package com.phishingdefense.backend.exception;

public class StageNotFoundException extends RuntimeException {

    public StageNotFoundException(Long stageId) {
        super("스테이지를 찾을 수 없습니다: " + stageId);
    }
}
