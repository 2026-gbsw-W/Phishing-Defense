package com.phishingdefense.backend.dto.game;

import java.util.List;

public record EvidenceConfirmResponse(
        Integer evidenceCollectionPercentage,
        List<EvidenceItemResponse> missedEvidence
) {
}
