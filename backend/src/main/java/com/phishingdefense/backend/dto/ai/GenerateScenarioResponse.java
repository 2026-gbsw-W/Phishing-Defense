package com.phishingdefense.backend.dto.ai;

public record GenerateScenarioResponse(
        Long scenarioId,
        String context,
        String initialMessage
) {
}
