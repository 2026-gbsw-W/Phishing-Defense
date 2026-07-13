package com.phishingdefense.backend.dto.ai;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AiChatResponseRequest(
        @NotNull Long recordId,
        @NotBlank String userMessage,
        String context
) {
}
