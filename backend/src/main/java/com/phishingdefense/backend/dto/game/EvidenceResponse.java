package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Evidence;

public record EvidenceResponse(
        Long evidenceId,
        String evidenceType,
        String evidenceValue,
        Integer messageTurn,
        Boolean submittedAtReport,
        Boolean validEvidence,
        String validityReason
) {
    public static EvidenceResponse from(Evidence evidence) {
        return new EvidenceResponse(
                evidence.getEvidenceId(),
                evidence.getEvidenceType(),
                evidence.getEvidenceValue(),
                evidence.getMessageTurn(),
                evidence.getSubmittedAtReport(),
                evidence.getValidEvidence(),
                evidence.getValidityReason()
        );
    }
}
