package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Stage;

public record StageResponse(
        Long stageId,
        Integer chapterId,
        String title,
        String initialMessage,
        String phishingType,
        Integer difficulty
) {
    public static StageResponse from(Stage stage) {
        return new StageResponse(
                stage.getStageId(),
                stage.getChapterId(),
                stage.getTitle(),
                stage.getInitialMessage(),
                stage.getPhishingType(),
                stage.getDifficulty()
        );
    }
}
