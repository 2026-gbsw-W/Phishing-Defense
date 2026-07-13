package com.phishingdefense.backend.dto.game;

public record ChatEvidenceResponse(
        String message,
        ChatEvidenceItemResponse evidence
) {
}
