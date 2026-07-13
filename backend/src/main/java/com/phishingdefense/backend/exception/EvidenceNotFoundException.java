package com.phishingdefense.backend.exception;

public class EvidenceNotFoundException extends RuntimeException {

    public EvidenceNotFoundException(Long evidenceId) {
        super("증거를 찾을 수 없습니다: " + evidenceId);
    }
}
