package com.phishingdefense.backend.dto.user;

import java.util.List;

public record UserInventoryResponse(
        Integer coins,
        Integer hints,
        List<String> boosters
) {
}
