package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * AI 모듈(/ai) {@code POST /chat/end}, {@code GET /report/{session_id}} 응답 스키마를 그대로 미러링한다.
 */
public record AiChatEndResponse(
        @JsonProperty("session_id") String sessionId,
        @JsonProperty("report") AiReportPayload report,
        @JsonProperty("evidences") List<AiEvidenceItem> evidences
) {
}
