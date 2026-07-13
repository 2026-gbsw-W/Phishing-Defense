package com.phishingdefense.backend.dto.game;

import jakarta.validation.constraints.NotBlank;

public record ChatSendRequest(
        @NotBlank String message
) {
}
