package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) {@code POST /chat/end} 요청 스키마를 그대로 미러링한다.
 */
public record AiChatEndRequestPayload(
        @JsonProperty("session_id") String sessionId
) {
}
