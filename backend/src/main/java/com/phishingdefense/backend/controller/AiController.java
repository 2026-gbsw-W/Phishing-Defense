package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.ai.AiChatResponseRequest;
import com.phishingdefense.backend.dto.ai.AiChatResponseResult;
import com.phishingdefense.backend.dto.ai.GenerateReportRequest;
import com.phishingdefense.backend.dto.ai.GenerateReportResponse;
import com.phishingdefense.backend.dto.ai.GenerateScenarioRequest;
import com.phishingdefense.backend.dto.ai.GenerateScenarioResponse;
import com.phishingdefense.backend.service.AiService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 내부용 AI 연동 API (PRD 14.4). 실제 AI 서버(/ai)와 직접 통신한다.
 * 세션(session_id)은 AI 서버가 관리하므로, 이 API의 호출 순서는
 * generate-scenario(세션 생성) → chat-response(대화 반복) → generate-report(세션 종료+분석) 순이다.
 */
@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;

    @PostMapping("/generate-scenario")
    public ResponseEntity<GenerateScenarioResponse> generateScenario(
            @Valid @RequestBody GenerateScenarioRequest request
    ) {
        return ResponseEntity.ok(aiService.generateScenario(request));
    }

    @PostMapping("/chat-response")
    public ResponseEntity<AiChatResponseResult> getChatResponse(
            @Valid @RequestBody AiChatResponseRequest request
    ) {
        return ResponseEntity.ok(aiService.getChatResponse(request));
    }

    @PostMapping("/generate-report")
    public ResponseEntity<GenerateReportResponse> generateReport(
            @Valid @RequestBody GenerateReportRequest request
    ) {
        return ResponseEntity.ok(aiService.generateReport(request));
    }
}
