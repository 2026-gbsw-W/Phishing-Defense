package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.DailyMissionResponse;
import com.phishingdefense.backend.dto.game.MissionCompleteRequest;
import com.phishingdefense.backend.dto.game.MissionCompleteResponse;
import com.phishingdefense.backend.security.UserPrincipal;
import com.phishingdefense.backend.service.MissionService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/missions")
@RequiredArgsConstructor
public class MissionController {

    private final MissionService missionService;

    @GetMapping("/daily")
    public ResponseEntity<List<DailyMissionResponse>> getDailyMissions(
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(missionService.getDailyMissions(principal.getUserId()));
    }

    @PostMapping("/{missionId}/complete")
    public ResponseEntity<MissionCompleteResponse> completeMission(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long missionId,
            @Valid @RequestBody MissionCompleteRequest request
    ) {
        return ResponseEntity.ok(missionService.completeMission(principal.getUserId(), missionId, request));
    }
}
