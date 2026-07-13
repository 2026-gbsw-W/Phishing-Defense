package com.phishingdefense.backend.dto.ai;

import jakarta.validation.constraints.NotNull;

public record GenerateScenarioRequest(
        @NotNull Integer difficulty,
        String weaknessType,
        String userHistory
) {
}
