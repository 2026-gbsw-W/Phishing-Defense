package com.phishingdefense.backend.service;

import com.phishingdefense.backend.client.AiClient;
import com.phishingdefense.backend.client.AiScenarioTypeMapper;
import com.phishingdefense.backend.dto.ai.AiChatResponseRequest;
import com.phishingdefense.backend.dto.ai.AiChatResponseResult;
import com.phishingdefense.backend.dto.ai.GenerateReportRequest;
import com.phishingdefense.backend.dto.ai.GenerateReportResponse;
import com.phishingdefense.backend.dto.ai.GenerateScenarioRequest;
import com.phishingdefense.backend.dto.ai.GenerateScenarioResponse;
import com.phishingdefense.backend.dto.training.AiChatEndResponse;
import com.phishingdefense.backend.dto.training.AiChatMessageResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 실제 AI 서버(/ai)와 직접 통신하는 서비스.
 * 세션은 AI 서버가 관리하며(session_id), 우리 쪽에서는 별도 DB 연동 없이 그대로 중계한다.
 */
@Service
@RequiredArgsConstructor
public class AiService {

    private static final String SCENARIO_START_MESSAGE = "안녕하세요.";

    private final AiClient aiClient;

    public GenerateScenarioResponse generateScenario(GenerateScenarioRequest request) {
        String scenarioType = StringUtils.hasText(request.weaknessType())
                ? AiScenarioTypeMapper.map(request.weaknessType())
                : null;

        AiChatMessageResponse response = aiClient.chat(null, SCENARIO_START_MESSAGE, scenarioType);

        return new GenerateScenarioResponse(response.sessionId(), scenarioType, response.answer());
    }

    public AiChatResponseResult getChatResponse(AiChatResponseRequest request) {
        AiChatMessageResponse response = aiClient.chat(request.sessionId(), request.userMessage(), null);
        return new AiChatResponseResult(response.answer(), List.of());
    }

    public GenerateReportResponse generateReport(GenerateReportRequest request) {
        AiChatEndResponse response = aiClient.endChat(request.sessionId());
        return new GenerateReportResponse(response.sessionId(), response.report());
    }
}
