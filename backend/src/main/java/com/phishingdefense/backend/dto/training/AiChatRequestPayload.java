package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) {@code POST /chat} 요청 스키마를 그대로 미러링한다.
 * session_id/scenario_type은 선택값이라 null이면 전송 필드에서 제외한다.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record AiChatRequestPayload(
        @JsonProperty("message") String message,
        @JsonProperty("session_id") String sessionId,
        @JsonProperty("scenario_type") String scenarioType
) {
}
