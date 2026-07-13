package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.ScenarioRecord;
import java.time.LocalDateTime;

public record ScenarioRecordResponse(
        Long recordId,
        Integer chapterId,
        Long scenarioId,
        Boolean correctJudgment,
        Integer hintsUsed,
        Integer starRating,
        Integer totalScore,
        Boolean completed,
        Boolean reported,
        LocalDateTime playedAt
) {
    public static ScenarioRecordResponse from(ScenarioRecord record) {
        return new ScenarioRecordResponse(
                record.getRecordId(),
                record.getChapterId(),
                record.getScenarioId(),
                record.getCorrectJudgment(),
                record.getHintsUsed(),
                record.getStarRating(),
                record.getTotalScore(),
                record.getCompleted(),
                record.getReported(),
                record.getPlayedAt()
        );
    }
}
