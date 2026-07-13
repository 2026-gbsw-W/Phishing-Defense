package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.ScenarioStartResponse;
import com.phishingdefense.backend.dto.game.ScenarioStatusResponse;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScenarioPlayService {

    private final StageRepository stageRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;

    @Transactional
    public ScenarioStartResponse start(Long userId, Long scenarioId) {
        Stage stage = stageRepository.findById(scenarioId)
                .orElseThrow(() -> new StageNotFoundException(scenarioId));

        ScenarioRecord record = ScenarioRecord.start(userId, stage.getChapterId(), stage.getStageId());
        ScenarioRecord saved = scenarioRecordRepository.save(record);

        return new ScenarioStartResponse(saved.getRecordId(), stage.getInitialMessage(), LocalDateTime.now());
    }

    public ScenarioStatusResponse getStatus(Long userId, Long recordId) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        return ScenarioStatusResponse.from(record);
    }

    private ScenarioRecord getOwnedRecordOrThrow(Long userId, Long recordId) {
        ScenarioRecord record = scenarioRecordRepository.findById(recordId)
                .orElseThrow(() -> new ScenarioRecordNotFoundException(recordId));

        if (!record.isOwnedBy(userId)) {
            throw new ScenarioRecordAccessDeniedException();
        }

        return record;
    }
}
