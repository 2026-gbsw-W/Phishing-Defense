package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.ai.AiChatResponseRequest;
import com.phishingdefense.backend.dto.ai.AiChatResponseResult;
import com.phishingdefense.backend.dto.ai.GenerateReportRequest;
import com.phishingdefense.backend.dto.ai.GenerateReportResponse;
import com.phishingdefense.backend.dto.ai.GenerateScenarioRequest;
import com.phishingdefense.backend.dto.ai.GenerateScenarioResponse;
import com.phishingdefense.backend.security.UserPrincipal;
import com.phishingdefense.backend.service.AiService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 내부용 AI 연동 API (PRD 14.4). 실제 AI 서버 연동 전까지 임시(mock) 로직으로 동작한다.
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
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody AiChatResponseRequest request
    ) {
        return ResponseEntity.ok(aiService.getChatResponse(principal.getUserId(), request));
    }

    @PostMapping("/generate-report")
    public ResponseEntity<GenerateReportResponse> generateReport(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody GenerateReportRequest request
    ) {
        return ResponseEntity.ok(aiService.generateReport(principal.getUserId(), request));
    }
}
