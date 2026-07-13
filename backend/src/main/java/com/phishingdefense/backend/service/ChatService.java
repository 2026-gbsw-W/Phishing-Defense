package com.phishingdefense.backend.service;

import com.phishingdefense.backend.client.AiClient;
import com.phishingdefense.backend.client.AiScenarioTypeMapper;
import com.phishingdefense.backend.dto.game.ChatEvidenceResponse;
import com.phishingdefense.backend.dto.game.ChatEvidenceItemResponse;
import com.phishingdefense.backend.dto.game.ChatHintResponse;
import com.phishingdefense.backend.dto.game.ChatHistoryEntryResponse;
import com.phishingdefense.backend.dto.game.ChatSendRequest;
import com.phishingdefense.backend.dto.game.ChatSendResponse;
import com.phishingdefense.backend.dto.game.ChatVoiceResponse;
import com.phishingdefense.backend.dto.training.AiChatEndResponse;
import com.phishingdefense.backend.dto.training.AiChatMessageResponse;
import com.phishingdefense.backend.dto.training.AiEvidenceResponse;
import com.phishingdefense.backend.dto.training.AiReportPayload;
import com.phishingdefense.backend.dto.training.TrainingResultResponse;
import com.phishingdefense.backend.dto.training.VoiceChatResult;
import com.phishingdefense.backend.entity.ChatHistory;
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
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import com.phishingdefense.backend.repository.TrainingEvidenceRepository;
import com.phishingdefense.backend.repository.TrainingResultRepository;
import com.phishingdefense.backend.repository.TrainingSessionRepository;
import com.phishingdefense.backend.repository.UserRepository;
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
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private static final String AI_MODEL_NAME = "ai-server";
    private static final String MOCK_HINT_TEXT = "(임시 힌트) 발신자 정보와 링크의 출처를 다시 한번 확인해보세요.";

    private final ScenarioRecordRepository scenarioRecordRepository;
    private final ChatHistoryRepository chatHistoryRepository;
    private final UserRepository userRepository;
    private final StageRepository stageRepository;
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

        return new ChatSendResponse(aiResponse.answer(), turn, List.of(), true);
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

        return new ChatHintResponse(MOCK_HINT_TEXT, user.getHints());
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
