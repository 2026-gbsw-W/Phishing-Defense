package com.phishingdefense.backend.dto.ai;

public record GenerateScenarioResponse(
        String sessionId,
        String scenarioType,
        String initialMessage
) {
}
