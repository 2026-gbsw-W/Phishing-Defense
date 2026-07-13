package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.EvidenceConfirmRequest;
import com.phishingdefense.backend.dto.game.EvidenceConfirmResponse;
import com.phishingdefense.backend.dto.game.EvidenceItemResponse;
import com.phishingdefense.backend.dto.game.JudgmentRequest;
import com.phishingdefense.backend.dto.game.JudgmentResponse;
import com.phishingdefense.backend.dto.game.ReportClaimResponse;
import com.phishingdefense.backend.dto.game.ScenarioReportResponse;
import com.phishingdefense.backend.dto.game.ScenarioStartResponse;
import com.phishingdefense.backend.dto.game.ScenarioStatusResponse;
import com.phishingdefense.backend.security.UserPrincipal;
import com.phishingdefense.backend.service.ScenarioPlayService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/scenarios")
@RequiredArgsConstructor
public class ScenarioController {

    private final ScenarioPlayService scenarioPlayService;

    @PostMapping("/{scenarioId}/start")
    public ResponseEntity<ScenarioStartResponse> start(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long scenarioId
    ) {
        ScenarioStartResponse response = scenarioPlayService.start(principal.getUserId(), scenarioId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{recordId}/status")
    public ResponseEntity<ScenarioStatusResponse> getStatus(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(scenarioPlayService.getStatus(principal.getUserId(), recordId));
    }

    @PostMapping("/{recordId}/judgment")
    public ResponseEntity<JudgmentResponse> judge(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId,
            @Valid @RequestBody JudgmentRequest request
    ) {
        return ResponseEntity.ok(scenarioPlayService.judge(principal.getUserId(), recordId, request));
    }

    @GetMapping("/{recordId}/evidence")
    public ResponseEntity<List<EvidenceItemResponse>> getEvidence(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(scenarioPlayService.getEvidence(principal.getUserId(), recordId));
    }

    @PostMapping("/{recordId}/evidence/confirm")
    public ResponseEntity<EvidenceConfirmResponse> confirmEvidence(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId,
            @Valid @RequestBody EvidenceConfirmRequest request
    ) {
        return ResponseEntity.ok(scenarioPlayService.confirmEvidence(principal.getUserId(), recordId, request));
    }

    @GetMapping("/{recordId}/report")
    public ResponseEntity<ScenarioReportResponse> getReport(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(scenarioPlayService.getReport(principal.getUserId(), recordId));
    }

    @PostMapping("/{recordId}/report/claim")
    public ResponseEntity<ReportClaimResponse> claimReport(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(scenarioPlayService.claimReport(principal.getUserId(), recordId));
    }
}
