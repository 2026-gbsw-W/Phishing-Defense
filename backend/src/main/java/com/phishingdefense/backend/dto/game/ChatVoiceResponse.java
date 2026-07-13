package com.phishingdefense.backend.dto.game;

public record ChatVoiceResponse(
        String userText,
        String aiText,
        int turn,
        String audioBase64,
        String audioContentType
) {
}
