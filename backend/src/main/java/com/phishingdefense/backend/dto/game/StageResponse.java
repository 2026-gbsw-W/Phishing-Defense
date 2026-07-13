package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Stage;

public record StageResponse(
        Long stageId,
        Integer chapterId,
        String title,
        String initialMessage,
        String phishingType,
        Integer difficulty,
        Boolean completed
) {
    public static StageResponse from(Stage stage) {
        return from(stage, false);
    }

    public static StageResponse from(Stage stage, boolean completed) {
        return new StageResponse(
                stage.getStageId(),
                stage.getChapterId(),
                stage.getTitle(),
                stage.getInitialMessage(),
                stage.getPhishingType(),
                stage.getDifficulty(),
                completed
        );
    }
}
