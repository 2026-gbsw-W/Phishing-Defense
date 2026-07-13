package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.ChapterProgress;
import java.time.LocalDateTime;

public record ChapterProgressResponse(
        Long progressId,
        Integer chapterId,
        Boolean completed,
        Integer bestStar,
        Integer totalAttempts,
        LocalDateTime firstClearAt,
        LocalDateTime lastAttemptAt
) {
    public static ChapterProgressResponse from(ChapterProgress progress) {
        return new ChapterProgressResponse(
                progress.getProgressId(),
                progress.getChapterId(),
                progress.getCompleted(),
                progress.getBestStar(),
                progress.getTotalAttempts(),
                progress.getFirstClearAt(),
                progress.getLastAttemptAt()
        );
    }
}
