package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.PhishingIndexEntry;
import java.time.LocalDateTime;

public record PhishingIndexResponse(
        Long phishingIndexId,
        Integer chapterId,
        Long scenarioId,
        LocalDateTime collectedAt
) {
    public static PhishingIndexResponse from(PhishingIndexEntry entry) {
        return new PhishingIndexResponse(
                entry.getPhishingIndexId(),
                entry.getChapterId(),
                entry.getScenarioId(),
                entry.getCollectedAt()
        );
    }
}
