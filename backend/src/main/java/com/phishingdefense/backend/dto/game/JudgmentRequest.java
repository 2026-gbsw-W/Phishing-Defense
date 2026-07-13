package com.phishingdefense.backend.dto.game;

import jakarta.validation.constraints.NotNull;

public record JudgmentRequest(
        @NotNull Boolean isPhishing
) {
}
