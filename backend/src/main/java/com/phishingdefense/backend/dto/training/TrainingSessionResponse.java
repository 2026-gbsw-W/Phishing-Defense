package com.phishingdefense.backend.dto.training;

import com.phishingdefense.backend.entity.TrainingSession;
import java.time.LocalDateTime;

public record TrainingSessionResponse(
        String sessionId,
        Long recordId,
        String scenarioType,
        LocalDateTime createdAt
) {
    public static TrainingSessionResponse from(TrainingSession session) {
        return new TrainingSessionResponse(
                session.getSessionId(),
                session.getRecordId(),
                session.getScenarioType(),
                session.getCreatedAt()
        );
    }
}
