package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) {@code POST /chat} 응답 스키마를 그대로 미러링한다.
 */
public record AiChatMessageResponse(
        @JsonProperty("session_id") String sessionId,
        @JsonProperty("answer") String answer
) {
}
