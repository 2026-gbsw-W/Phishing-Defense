package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.ai.AiChatResponseRequest;
import com.phishingdefense.backend.dto.ai.AiChatResponseResult;
import com.phishingdefense.backend.dto.ai.GenerateReportRequest;
import com.phishingdefense.backend.dto.ai.GenerateReportResponse;
import com.phishingdefense.backend.dto.ai.GenerateScenarioRequest;
import com.phishingdefense.backend.dto.ai.GenerateScenarioResponse;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * 실제 AI 서버(/ai) 연동 전까지 임시로 사용하는 모의(mock) 서비스.
 * 시나리오 생성/채팅응답/리포트생성 모두 고정 로직이나 기존 데이터로 대체한다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AiService {

    private static final String MOCK_AI_MESSAGE = "(임시 응답) 메시지를 확인했습니다. 계속 대화를 이어가 주세요.";

    private final StageRepository stageRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;

    public GenerateScenarioResponse generateScenario(GenerateScenarioRequest request) {
        Stage stage = pickStage(request.difficulty(), request.weaknessType());
        return new GenerateScenarioResponse(stage.getStageId(), stage.getContext(), stage.getInitialMessage());
    }

    public AiChatResponseResult getChatResponse(Long userId, AiChatResponseRequest request) {
        ScenarioRecord record = scenarioRecordRepository.findById(request.recordId())
                .orElseThrow(() -> new ScenarioRecordNotFoundException(request.recordId()));
        if (!record.isOwnedBy(userId)) {
            throw new ScenarioRecordAccessDeniedException();
        }

        return new AiChatResponseResult(MOCK_AI_MESSAGE, List.of());
    }

    public GenerateReportResponse generateReport(Long userId, GenerateReportRequest request) {
        ScenarioRecord record = scenarioRecordRepository.findById(request.recordId())
                .orElseThrow(() -> new ScenarioRecordNotFoundException(request.recordId()));
        if (!record.isOwnedBy(userId)) {
            throw new ScenarioRecordAccessDeniedException();
        }

        Map<String, Object> reportJson = Map.of(
                "recordId", record.getRecordId(),
                "generatedAt", LocalDateTime.now().toString(),
                "summary", "(임시 리포트입니다 - AI 연동 전 임시 응답)"
        );

        return new GenerateReportResponse(reportJson);
    }

    private Stage pickStage(Integer difficulty, String weaknessType) {
        if (StringUtils.hasText(weaknessType)) {
            List<Stage> matched = stageRepository.findByDifficultyAndPhishingType(difficulty, weaknessType);
            if (!matched.isEmpty()) {
                return matched.get(0);
            }
        }

        List<Stage> byDifficulty = stageRepository.findByDifficulty(difficulty);
        if (!byDifficulty.isEmpty()) {
            return byDifficulty.get(0);
        }

        return stageRepository.findAll().stream()
                .findFirst()
                .orElseThrow(() -> new StageNotFoundException(-1L));
    }
}
