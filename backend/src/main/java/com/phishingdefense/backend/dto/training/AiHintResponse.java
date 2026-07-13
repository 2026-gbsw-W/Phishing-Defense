package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) {@code POST /hint} 응답 스키마를 그대로 미러링한다.
 */
public record AiHintResponse(
        @JsonProperty("session_id") String sessionId,
        @JsonProperty("hint") String hint,
        @JsonProperty("hint_count") Integer hintCount
) {
}
