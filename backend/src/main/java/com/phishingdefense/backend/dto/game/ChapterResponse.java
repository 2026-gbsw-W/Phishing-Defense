package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.Chapter;

public record ChapterResponse(
        Integer chapterId,
        String title,
        String description,
        Integer difficulty,
        Integer scenarioCount,
        Integer orderIndex
) {
    public static ChapterResponse from(Chapter chapter) {
        return new ChapterResponse(
                chapter.getChapterId(),
                chapter.getTitle(),
                chapter.getDescription(),
                chapter.getDifficulty(),
                chapter.getScenarioCount(),
                chapter.getOrderIndex()
        );
    }
}
