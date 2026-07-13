package com.phishingdefense.backend.dto.ai;

import java.util.List;

public record AiChatResponseResult(
        String aiMessage,
        List<ExtractedDataItem> extractedData
) {
}
