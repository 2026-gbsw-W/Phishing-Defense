package com.phishingdefense.backend.dto.game;

import java.util.List;

public record ChatSendResponse(
        String aiResponse,
        Integer turn,
        List<ExtractedEvidenceItem> extractedEvidence,
        Boolean hintAvailable
) {
}
