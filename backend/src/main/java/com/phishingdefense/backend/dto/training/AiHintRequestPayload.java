package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AiHintRequestPayload(
        @JsonProperty("session_id") String sessionId
) {
}
