package com.phishingdefense.backend.dto.game;

import java.time.LocalDateTime;

public record ScenarioStartResponse(
        Long recordId,
        String initialMessage,
        LocalDateTime timestamp
) {
}
