package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.ScenarioRecord;

public record ScenarioStatusResponse(
        Long recordId,
        Long scenarioId,
        Integer stage,
        Integer currentTurn,
        Boolean isCompleted,
        Integer hintsUsed
) {
    public static ScenarioStatusResponse from(ScenarioRecord record) {
        return new ScenarioStatusResponse(
                record.getRecordId(),
                record.getScenarioId(),
                record.getCurrentStage(),
                record.getCurrentTurn(),
                record.getCompleted(),
                record.getHintsUsed()
        );
    }
}
