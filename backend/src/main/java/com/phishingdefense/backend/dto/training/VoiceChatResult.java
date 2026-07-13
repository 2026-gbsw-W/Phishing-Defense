package com.phishingdefense.backend.dto.training;

import org.springframework.http.MediaType;

public record VoiceChatResult(
        String sessionId,
        String userText,
        String aiText,
        byte[] audioContent,
        MediaType contentType
) {
}
