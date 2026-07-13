package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.TrainingEvidence;

public record ChatEvidenceItemResponse(
        String evidenceId,
        String speaker,
        String message
) {
    public static ChatEvidenceItemResponse from(TrainingEvidence evidence) {
        return new ChatEvidenceItemResponse(evidence.getEvidenceId(), evidence.getSpeaker(), evidence.getMessage());
    }
}
