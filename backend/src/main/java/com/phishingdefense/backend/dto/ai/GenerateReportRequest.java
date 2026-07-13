package com.phishingdefense.backend.dto.ai;

import jakarta.validation.constraints.NotNull;

public record GenerateReportRequest(
        @NotNull Long recordId
) {
}
