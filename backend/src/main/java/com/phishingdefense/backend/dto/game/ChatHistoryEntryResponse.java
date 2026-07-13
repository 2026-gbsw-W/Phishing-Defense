package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.ChatHistory;
import java.time.LocalDateTime;

public record ChatHistoryEntryResponse(
        Integer turn,
        String sender,
        String message,
        LocalDateTime timestamp
) {
    public static ChatHistoryEntryResponse from(ChatHistory chat) {
        return new ChatHistoryEntryResponse(
                chat.getTurn(),
                chat.getSender(),
                chat.getMessageText(),
                chat.getCreatedAt()
        );
    }
}
