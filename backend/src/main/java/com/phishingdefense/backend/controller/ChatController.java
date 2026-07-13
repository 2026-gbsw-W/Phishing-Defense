package com.phishingdefense.backend.controller;

import com.phishingdefense.backend.dto.game.ChatEvidenceRequest;
import com.phishingdefense.backend.dto.game.ChatEvidenceResponse;
import com.phishingdefense.backend.dto.game.ChatHintResponse;
import com.phishingdefense.backend.dto.game.ChatHistoryEntryResponse;
import com.phishingdefense.backend.dto.game.ChatSendRequest;
import com.phishingdefense.backend.dto.game.ChatSendResponse;
import com.phishingdefense.backend.dto.game.ChatVoiceResponse;
import com.phishingdefense.backend.dto.training.TrainingResultResponse;
import com.phishingdefense.backend.security.UserPrincipal;
import com.phishingdefense.backend.service.ChatService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/{recordId}/send")
    public ResponseEntity<ChatSendResponse> sendMessage(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId,
            @Valid @RequestBody ChatSendRequest request
    ) {
        return ResponseEntity.ok(chatService.sendMessage(principal.getUserId(), recordId, request));
    }

    @GetMapping("/{recordId}/history")
    public ResponseEntity<List<ChatHistoryEntryResponse>> getHistory(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(chatService.getHistory(principal.getUserId(), recordId));
    }

    @PostMapping("/{recordId}/hint")
    public ResponseEntity<ChatHintResponse> useHint(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(chatService.useHint(principal.getUserId(), recordId));
    }

    @PostMapping(value = "/{recordId}/voice", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ChatVoiceResponse> sendVoiceMessage(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId,
            @RequestParam("file") MultipartFile audioFile
    ) {
        return ResponseEntity.ok(chatService.sendVoiceMessage(principal.getUserId(), recordId, audioFile));
    }

    @PostMapping("/{recordId}/evidence")
    public ResponseEntity<ChatEvidenceResponse> saveEvidence(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId,
            @Valid @RequestBody ChatEvidenceRequest request
    ) {
        return ResponseEntity.ok(chatService.saveEvidence(principal.getUserId(), recordId, request.message()));
    }

    @PostMapping("/{recordId}/end")
    public ResponseEntity<TrainingResultResponse> endTraining(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long recordId
    ) {
        return ResponseEntity.ok(chatService.endTraining(principal.getUserId(), recordId));
    }
}
