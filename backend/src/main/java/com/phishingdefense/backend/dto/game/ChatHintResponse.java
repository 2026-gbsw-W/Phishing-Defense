package com.phishingdefense.backend.dto.game;

public record ChatHintResponse(
        String hintText,
        Integer remainingHints
) {
}
