package com.phishingdefense.backend.dto.ai;

import jakarta.validation.constraints.NotBlank;

public record AiChatResponseRequest(
        @NotBlank String sessionId,
        @NotBlank String userMessage
) {
}
