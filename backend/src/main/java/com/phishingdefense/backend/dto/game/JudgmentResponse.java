package com.phishingdefense.backend.dto.game;

public record JudgmentResponse(
        Boolean isCorrect,
        String feedback,
        Integer stageProgression
) {
}
