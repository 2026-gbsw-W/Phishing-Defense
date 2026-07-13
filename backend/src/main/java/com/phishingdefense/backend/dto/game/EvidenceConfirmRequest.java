package com.phishingdefense.backend.dto.game;

import jakarta.validation.constraints.NotNull;
import java.util.List;

public record EvidenceConfirmRequest(
        @NotNull List<Long> selectedEvidenceIds
) {
}
