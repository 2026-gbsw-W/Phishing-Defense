package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Evidence;

public record EvidenceItemResponse(
        Long evidenceId,
        String type,
        String value,
        Integer importance
) {
    public static EvidenceItemResponse from(Evidence evidence) {
        return new EvidenceItemResponse(
                evidence.getEvidenceId(),
                evidence.getEvidenceType(),
                evidence.getEvidenceValue(),
                evidence.getImportanceLevel()
        );
    }
}
