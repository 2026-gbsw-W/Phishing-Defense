package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.ChatHintResponse;
import com.phishingdefense.backend.dto.game.ChatHistoryEntryResponse;
import com.phishingdefense.backend.dto.game.ChatSendRequest;
import com.phishingdefense.backend.dto.game.ChatSendResponse;
import com.phishingdefense.backend.entity.ChatHistory;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.InsufficientHintsException;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordAlreadyCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.ChatHistoryRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * AI 서버 연동 전까지 임시로 사용하는 모의(mock) 채팅 서비스.
 * 실제 AI 응답 생성/증거 추출 대신 고정된 플레이스홀더 값을 반환한다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private static final String MOCK_AI_MODEL = "mock";
    private static final String MOCK_MODEL_VERSION = "stub-1.0";
    private static final String MOCK_AI_RESPONSE = "(임시 응답) 메시지를 확인했습니다. 계속 대화를 이어가 주세요.";
    private static final String MOCK_HINT_TEXT = "(임시 힌트) 발신자 정보와 링크의 출처를 다시 한번 확인해보세요.";

    private final ScenarioRecordRepository scenarioRecordRepository;
    private final ChatHistoryRepository chatHistoryRepository;
    private final UserRepository userRepository;

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

        return new ChatSendResponse(MOCK_AI_RESPONSE, turn, List.of(), true);
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
