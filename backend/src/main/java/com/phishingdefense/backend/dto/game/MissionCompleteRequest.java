package com.phishingdefense.backend.dto.game;

import jakarta.validation.constraints.NotNull;

public record MissionCompleteRequest(
        @NotNull Long recordId
) {
}
