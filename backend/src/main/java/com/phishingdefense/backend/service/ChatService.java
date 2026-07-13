package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.ChatHintResponse;
import com.phishingdefense.backend.dto.game.ChatHistoryEntryResponse;
import com.phishingdefense.backend.dto.game.ChatSendRequest;
import com.phishingdefense.backend.dto.game.ChatSendResponse;
import com.phishingdefense.backend.dto.game.ExtractedEvidenceItem;
import com.phishingdefense.backend.entity.ChatHistory;
import com.phishingdefense.backend.entity.Evidence;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.InsufficientHintsException;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordAlreadyCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.ChatHistoryRepository;
import com.phishingdefense.backend.repository.EvidenceRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import com.phishingdefense.backend.repository.UserRepository;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * AI 서버 연동 전까지 임시로 사용하는 모의(mock) 채팅 서비스.
 * 실제 AI 응답 생성은 고정된 플레이스홀더 값을 반환하지만, 증거 추출은
 * {@link EvidenceExtractor}를 통해 시나리오의 required_evidence 카탈로그와
 * 키워드를 매칭하는 규칙 기반 방식으로 실제 동작한다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private static final String MOCK_AI_MODEL = "mock";
    private static final String MOCK_MODEL_VERSION = "stub-1.0";
    private static final String MOCK_AI_RESPONSE = "(임시 응답) 메시지를 확인했습니다. 계속 대화를 이어가 주세요.";
    private static final String FALLBACK_HINT_TEXT = "발신자 정보와 링크의 출처를 다시 한번 확인해보세요.";

    private final ScenarioRecordRepository scenarioRecordRepository;
    private final ChatHistoryRepository chatHistoryRepository;
    private final UserRepository userRepository;
    private final StageRepository stageRepository;
    private final EvidenceRepository evidenceRepository;
    private final EvidenceExtractor evidenceExtractor;

    @Transactional
    public ChatSendResponse sendMessage(Long userId, Long recordId, ChatSendRequest request) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        int turn = record.advanceTurn();

        chatHistoryRepository.save(ChatHistory.userMessage(recordId, turn, request.message()));
        chatHistoryRepository.save(
                ChatHistory.aiMessage(recordId, turn, MOCK_AI_RESPONSE, MOCK_AI_MODEL, MOCK_MODEL_VERSION));

        Stage stage = stageRepository.findById(record.getScenarioId())
                .orElseThrow(() -> new StageNotFoundException(record.getScenarioId()));
        List<ExtractedEvidenceItem> newlyFound =
                extractNewEvidence(stage, recordId, turn, MOCK_AI_RESPONSE);

        return new ChatSendResponse(MOCK_AI_RESPONSE, turn, newlyFound, true);
    }

    private List<ExtractedEvidenceItem> extractNewEvidence(Stage stage, Long recordId, int turn, String aiText) {
        List<ExtractedEvidenceItem> newlyFound = new ArrayList<>();
        for (RequiredEvidenceEntry entry : evidenceExtractor.match(stage.getRequiredEvidence(), aiText)) {
            if (evidenceRepository.existsByRecordIdAndEvidenceType(recordId, entry.type())) {
                continue;
            }
            evidenceRepository.save(
                    Evidence.discovered(recordId, entry.type(), entry.value(), turn, entry.importance()));
            newlyFound.add(new ExtractedEvidenceItem(entry.type(), entry.value()));
        }
        return newlyFound;
    }

    public List<ChatHistoryEntryResponse> getHistory(Long userId, Long recordId) {
        getOwnedRecordOrThrow(userId, recordId);

        return chatHistoryRepository.findByRecordIdOrderByTurnAsc(recordId).stream()
                .map(ChatHistoryEntryResponse::from)
                .toList();
    }

    @Transactional
    public ChatHintResponse useHint(Long userId, Long recordId) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
        if (!user.hasHints()) {
            throw new InsufficientHintsException();
        }

        user.decrementHints();
        record.useHint();

        return new ChatHintResponse(buildHintText(record, recordId), user.getHints());
    }

    /**
     * 아직 발견되지 않은 required_evidence 항목 중 중요도가 가장 높은 것을 힌트로
     * 알려주는 규칙 기반 힌트. 모든 증거를 이미 찾았거나 카탈로그가 비어 있으면
     * 일반적인 안내 문구로 대체한다.
     */
    private String buildHintText(ScenarioRecord record, Long recordId) {
        Stage stage = stageRepository.findById(record.getScenarioId())
                .orElseThrow(() -> new StageNotFoundException(record.getScenarioId()));

        List<String> foundTypes = evidenceRepository.findByRecordId(recordId).stream()
                .map(Evidence::getEvidenceType)
                .toList();

        return evidenceExtractor.parseCatalog(stage.getRequiredEvidence()).stream()
                .filter(entry -> !foundTypes.contains(entry.type()))
                .max((a, b) -> Integer.compare(
                        a.importance() == null ? 0 : a.importance(),
                        b.importance() == null ? 0 : b.importance()))
                .map(entry -> "힌트: " + entry.value() + "이(가) 있는지 다시 확인해보세요.")
                .orElse(FALLBACK_HINT_TEXT);
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
