package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.ChapterResponse;
import com.phishingdefense.backend.dto.game.StageResponse;
import com.phishingdefense.backend.entity.Chapter;
import com.phishingdefense.backend.exception.ChapterNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.repository.ChapterRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChapterService {

    private final ChapterRepository chapterRepository;
    private final StageRepository stageRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;

    public List<ChapterResponse> getChapters() {
        return chapterRepository.findAllByOrderByOrderIndexAsc().stream()
                .map(ChapterResponse::from)
                .toList();
    }

    public ChapterResponse getChapter(Integer chapterId) {
        return ChapterResponse.from(getChapterOrThrow(chapterId));
    }

    public List<StageResponse> getStages(Long userId, Integer chapterId) {
        getChapterOrThrow(chapterId);

        Set<Long> completedStageIds = scenarioRecordRepository.findByUserIdAndChapterId(userId, chapterId).stream()
                .filter(record -> Boolean.TRUE.equals(record.isCompleted()))
                .map(record -> record.getScenarioId())
                .collect(Collectors.toSet());

        return stageRepository.findByChapterIdOrderByStageIdAsc(chapterId).stream()
                .map(stage -> StageResponse.from(stage, completedStageIds.contains(stage.getStageId())))
                .toList();
    }

    public StageResponse getStage(Long stageId) {
        return StageResponse.from(
                stageRepository.findById(stageId)
                        .orElseThrow(() -> new StageNotFoundException(stageId))
        );
    }

    private Chapter getChapterOrThrow(Integer chapterId) {
        return chapterRepository.findById(chapterId)
                .orElseThrow(() -> new ChapterNotFoundException(chapterId));
    }
}
