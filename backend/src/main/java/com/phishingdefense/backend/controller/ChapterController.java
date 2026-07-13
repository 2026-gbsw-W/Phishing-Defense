package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.ChapterResponse;
import com.phishingdefense.backend.dto.game.StageResponse;
import com.phishingdefense.backend.service.ChapterService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/chapters")
@RequiredArgsConstructor
public class ChapterController {

    private final ChapterService chapterService;

    @GetMapping
    public ResponseEntity<List<ChapterResponse>> getChapters() {
        return ResponseEntity.ok(chapterService.getChapters());
    }

    @GetMapping("/{chapterId}")
    public ResponseEntity<ChapterResponse> getChapter(@PathVariable Integer chapterId) {
        return ResponseEntity.ok(chapterService.getChapter(chapterId));
    }

    @GetMapping("/{chapterId}/stages")
    public ResponseEntity<List<StageResponse>> getStages(@PathVariable Integer chapterId) {
        return ResponseEntity.ok(chapterService.getStages(chapterId));
    }
}
