package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.AttendanceStatusResponse;
import com.phishingdefense.backend.security.UserPrincipal;
import com.phishingdefense.backend.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    @GetMapping
    public ResponseEntity<AttendanceStatusResponse> getStatus(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(attendanceService.getStatus(principal.getUserId()));
    }
}
