package com.phishingdefense.backend.dto.ai;

import com.phishingdefense.backend.dto.training.AiReportPayload;

public record GenerateReportResponse(
        String sessionId,
        AiReportPayload report
) {
}
