package com.phishingdefense.backend.exception;

public class ReportAlreadyClaimedException extends RuntimeException {

    public ReportAlreadyClaimedException(Long recordId) {
        super("이미 보상을 수령한 플레이입니다: " + recordId);
    }
}
