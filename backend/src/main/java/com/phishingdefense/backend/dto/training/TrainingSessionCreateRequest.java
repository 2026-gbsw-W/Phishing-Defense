package com.phishingdefense.backend.dto.training;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

public record TrainingSessionCreateRequest(
        @NotBlank String sessionId,

        @NotNull Long recordId,

        @NotBlank
        @Pattern(regexp = "^(prosecutor|bank|family|delivery|loan)$",
                message = "scenarioType은 prosecutor, bank, family, delivery, loan 중 하나여야 합니다.")
        String scenarioType
) {
}
