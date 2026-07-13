package com.phishingdefense.backend.dto.ai;

import java.util.Map;

public record GenerateReportResponse(
        Map<String, Object> reportJson
) {
}
