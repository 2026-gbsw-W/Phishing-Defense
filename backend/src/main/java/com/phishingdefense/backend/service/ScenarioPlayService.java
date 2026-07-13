package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.EvidenceConfirmRequest;
import com.phishingdefense.backend.dto.game.EvidenceConfirmResponse;
import com.phishingdefense.backend.dto.game.EvidenceItemResponse;
import com.phishingdefense.backend.dto.game.JudgmentRequest;
import com.phishingdefense.backend.dto.game.JudgmentResponse;
import com.phishingdefense.backend.dto.game.ScenarioStartResponse;
import com.phishingdefense.backend.dto.game.ScenarioStatusResponse;
import com.phishingdefense.backend.entity.Evidence;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordAlreadyCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.repository.EvidenceRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScenarioPlayService {

    private static final String CORRECT_JUDGMENT_FEEDBACK = "정확한 판단입니다! 다음 단계로 진행합니다.";
    private static final String INCORRECT_JUDGMENT_FEEDBACK = "다시 한번 생각해보세요.";

    private final StageRepository stageRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;
    private final EvidenceRepository evidenceRepository;

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

    @Transactional
    public JudgmentResponse judge(Long userId, Long recordId, JudgmentRequest request) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        Stage stage = stageRepository.findById(record.getScenarioId())
                .orElseThrow(() -> new StageNotFoundException(record.getScenarioId()));

        boolean isCorrect = request.isPhishing().equals(stage.getPhishing());
        int stageProgression = record.recordJudgment(isCorrect);

        String feedback = isCorrect ? CORRECT_JUDGMENT_FEEDBACK : INCORRECT_JUDGMENT_FEEDBACK;
        return new JudgmentResponse(isCorrect, feedback, stageProgression);
    }

    public List<EvidenceItemResponse> getEvidence(Long userId, Long recordId) {
        getOwnedRecordOrThrow(userId, recordId);
        return evidenceRepository.findByRecordId(recordId).stream()
                .map(EvidenceItemResponse::from)
                .toList();
    }

    @Transactional
    public EvidenceConfirmResponse confirmEvidence(Long userId, Long recordId, EvidenceConfirmRequest request) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        List<Evidence> allEvidence = evidenceRepository.findByRecordId(recordId);
        Set<Long> selectedIds = Set.copyOf(request.selectedEvidenceIds());

        List<Evidence> selected = allEvidence.stream()
                .filter(evidence -> selectedIds.contains(evidence.getEvidenceId()))
                .toList();
        List<Evidence> missed = allEvidence.stream()
                .filter(evidence -> !selectedIds.contains(evidence.getEvidenceId()))
                .toList();

        selected.forEach(Evidence::markSubmitted);
        record.recordEvidenceSubmission(allEvidence.size(), selected.size());

        int percentage = allEvidence.isEmpty() ? 0 : Math.round(selected.size() * 100f / allEvidence.size());

        return new EvidenceConfirmResponse(percentage, missed.stream().map(EvidenceItemResponse::from).toList());
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
