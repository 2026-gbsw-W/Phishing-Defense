package com.phishingdefense.backend.dto.game;

import java.util.List;

public record EvidenceAnalysisResponse(
        Integer submittedCount,
        Integer totalCount,
        List<EvidenceItemResponse> missedEvidence
) {
}
