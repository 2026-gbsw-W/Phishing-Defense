package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) 증거 항목 스키마를 그대로 미러링한다.
 */
public record AiEvidenceItem(
        @JsonProperty("evidence_id") String evidenceId,
        @JsonProperty("speaker") String speaker,
        @JsonProperty("message") String message,
        @JsonProperty("created_at") String createdAt
) {
}
