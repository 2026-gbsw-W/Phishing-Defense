package com.phishingdefense.backend.dto.game;

import java.util.List;

public record ScenarioReportResponse(
        Integer accuracyScore,
        Integer starRating,
        Integer xpEarned,
        String detailedFeedback,
        EvidenceAnalysisResponse evidenceAnalysis,
        List<String> recommendations
) {
}
