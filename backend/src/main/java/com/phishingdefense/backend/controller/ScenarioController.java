package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.ScenarioStartResponse;
import com.phishingdefense.backend.dto.game.ScenarioStatusResponse;
import com.phishingdefense.backend.security.UserPrincipal;
import com.phishingdefense.backend.service.ScenarioPlayService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
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
}
