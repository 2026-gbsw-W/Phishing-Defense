package com.phishingdefense.backend.service;

import com.phishingdefense.backend.client.AiClient;
import com.phishingdefense.backend.client.AiScenarioTypeMapper;
import com.phishingdefense.backend.dto.game.ChatEvidenceItemResponse;
import com.phishingdefense.backend.dto.game.ChatEvidenceResponse;
import com.phishingdefense.backend.dto.game.ChatHintResponse;
import com.phishingdefense.backend.dto.game.ChatHistoryEntryResponse;
import com.phishingdefense.backend.dto.game.ChatSendRequest;
import com.phishingdefense.backend.dto.game.ChatSendResponse;
import com.phishingdefense.backend.dto.game.ChatVoiceResponse;
import com.phishingdefense.backend.dto.game.ExtractedEvidenceItem;
import com.phishingdefense.backend.dto.training.AiChatEndResponse;
import com.phishingdefense.backend.dto.training.AiChatMessageResponse;
import com.phishingdefense.backend.dto.training.AiEvidenceResponse;
import com.phishingdefense.backend.dto.training.AiReportPayload;
import com.phishingdefense.backend.dto.training.TrainingResultResponse;
import com.phishingdefense.backend.dto.training.VoiceChatResult;
import com.phishingdefense.backend.entity.ChatHistory;
import com.phishingdefense.backend.entity.Evidence;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.entity.TrainingEvidence;
import com.phishingdefense.backend.entity.TrainingResult;
import com.phishingdefense.backend.entity.TrainingSession;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.InsufficientHintsException;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordAlreadyCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.exception.TrainingSessionNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.ChatHistoryRepository;
import com.phishingdefense.backend.repository.EvidenceRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import com.phishingdefense.backend.repository.TrainingEvidenceRepository;
import com.phishingdefense.backend.repository.TrainingResultRepository;
import com.phishingdefense.backend.repository.TrainingSessionRepository;
import com.phishingdefense.backend.repository.UserRepository;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

/**
 * 실제 AI 서버(/chat, /chat/end)와 연동하는 채팅 서비스.
 * 스테이지 플레이 1회(ScenarioRecord)당 하나의 AI 훈련 세션(TrainingSession)을 유지한다.
 * 증거 추출은 {@link EvidenceExtractor}를 통해 AI 응답 텍스트에서 시나리오의
 * required_evidence 카탈로그와 키워드를 매칭하는 규칙 기반 방식으로 동작한다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private static final String AI_MODEL_NAME = "ai-server";
    private static final String FALLBACK_HINT_TEXT = "발신자 정보와 링크의 출처를 다시 한번 확인해보세요.";

    private final ScenarioRecordRepository scenarioRecordRepository;
    private final ChatHistoryRepository chatHistoryRepository;
    private final UserRepository userRepository;
    private final StageRepository stageRepository;
    private final EvidenceRepository evidenceRepository;
    private final EvidenceExtractor evidenceExtractor;
    private final TrainingSessionRepository trainingSessionRepository;
    private final TrainingResultRepository trainingResultRepository;
    private final TrainingEvidenceRepository trainingEvidenceRepository;
    private final AiClient aiClient;

    @Transactional
    public ChatSendResponse sendMessage(Long userId, Long recordId, ChatSendRequest request) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        TrainingSession session = trainingSessionRepository.findByRecordId(recordId)
                .orElseGet(() -> createTrainingSession(userId, record));

        int turn = record.advanceTurn();
        chatHistoryRepository.save(ChatHistory.userMessage(recordId, turn, request.message()));

        AiChatMessageResponse aiResponse = aiClient.chat(session.getSessionId(), request.message(), session.getScenarioType());

        chatHistoryRepository.save(
                ChatHistory.aiMessage(recordId, turn, aiResponse.answer(), AI_MODEL_NAME, null));

        Stage stage = stageRepository.findById(record.getScenarioId())
                .orElseThrow(() -> new StageNotFoundException(record.getScenarioId()));
        List<ExtractedEvidenceItem> newlyFound = extractNewEvidence(stage, recordId, turn, aiResponse.answer());

        return new ChatSendResponse(aiResponse.answer(), turn, newlyFound, true);
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

    @Transactional
    public ChatVoiceResponse sendVoiceMessage(Long userId, Long recordId, MultipartFile audioFile) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        TrainingSession session = trainingSessionRepository.findByRecordId(recordId)
                .orElseGet(() -> createTrainingSession(userId, record));

        VoiceChatResult result = aiClient.voiceChat(session.getSessionId(), session.getScenarioType(), audioFile);

        int turn = record.advanceTurn();
        chatHistoryRepository.save(ChatHistory.userMessage(recordId, turn, result.userText()));
        chatHistoryRepository.save(
                ChatHistory.aiMessage(recordId, turn, result.aiText(), AI_MODEL_NAME, null));

        return new ChatVoiceResponse(
                result.userText(),
                result.aiText(),
                turn,
                Base64.getEncoder().encodeToString(result.audioContent()),
                result.contentType() != null ? result.contentType().toString() : "audio/mpeg"
        );
    }

    @Transactional
    public ChatEvidenceResponse saveEvidence(Long userId, Long recordId, String message) {
        getOwnedRecordOrThrow(userId, recordId);

        TrainingSession session = trainingSessionRepository.findByRecordId(recordId)
                .orElseThrow(() -> new TrainingSessionNotFoundException("record:" + recordId));

        AiEvidenceResponse response = aiClient.saveEvidence(session.getSessionId(), message);

        TrainingEvidence evidence = TrainingEvidence.of(
                response.evidence().evidenceId(),
                session.getSessionId(),
                response.evidence().speaker(),
                response.evidence().message()
        );
        trainingEvidenceRepository.save(evidence);

        return new ChatEvidenceResponse(response.message(), ChatEvidenceItemResponse.from(evidence));
    }

    @Transactional
    public TrainingResultResponse endTraining(Long userId, Long recordId) {
        getOwnedRecordOrThrow(userId, recordId);

        TrainingSession session = trainingSessionRepository.findByRecordId(recordId)
                .orElseThrow(() -> new TrainingSessionNotFoundException("record:" + recordId));

        AiChatEndResponse response = aiClient.endChat(session.getSessionId());
        AiReportPayload report = response.report();

        TrainingResult result = TrainingResult.record(
                session.getSessionId(),
                report.personalInfoRequested(),
                report.accountNumberRequested(),
                report.moneyRequested(),
                report.urgencyCreated(),
                report.authorityImpersonation(),
                report.suspiciousLink(),
                report.userFellForIt(),
                report.riskScore(),
                report.dangerousMessages(),
                report.evidenceFeedback(),
                report.goodPoints(),
                report.mistakes(),
                report.improvementTips()
        );
        trainingResultRepository.save(result);

        return TrainingResultResponse.from(result);
    }

    private TrainingSession createTrainingSession(Long userId, ScenarioRecord record) {
        Stage stage = stageRepository.findById(record.getScenarioId())
                .orElseThrow(() -> new StageNotFoundException(record.getScenarioId()));

        String scenarioType = AiScenarioTypeMapper.map(stage.getPhishingType());
        String sessionId = UUID.randomUUID().toString();

        return trainingSessionRepository.save(
                TrainingSession.create(sessionId, userId, record.getRecordId(), scenarioType));
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
