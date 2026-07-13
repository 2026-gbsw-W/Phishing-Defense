package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) {@code POST /evidence} 응답 스키마를 그대로 미러링한다.
 */
public record AiEvidenceResponse(
        @JsonProperty("message") String message,
        @JsonProperty("evidence") AiEvidenceItem evidence
) {
}
