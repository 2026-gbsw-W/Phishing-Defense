package com.phishingdefense.backend.dto.ai;

import jakarta.validation.constraints.NotBlank;

public record GenerateReportRequest(
        @NotBlank String sessionId
) {
}
