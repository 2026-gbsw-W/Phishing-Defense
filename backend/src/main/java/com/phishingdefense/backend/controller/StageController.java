package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.StageResponse;
import com.phishingdefense.backend.service.ChapterService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/stages")
@RequiredArgsConstructor
public class StageController {

    private final ChapterService chapterService;

    @GetMapping("/{stageId}")
    public ResponseEntity<StageResponse> getStage(@PathVariable Long stageId) {
        return ResponseEntity.ok(chapterService.getStage(stageId));
    }
}
