package com.phishingdefense.backend.dto.game;

public record ReportClaimResponse(
        Integer xpAdded,
        Boolean levelUp,
        Integer newBalance
) {
}
