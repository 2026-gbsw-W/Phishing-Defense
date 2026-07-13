package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AiEvidenceRequestPayload(
        @JsonProperty("session_id") String sessionId,
        @JsonProperty("message") String message,
        @JsonProperty("speaker") String speaker
) {
}
