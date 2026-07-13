package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.ChatHistory;
import java.time.LocalDateTime;

public record ChatMessageResponse(
        Long chatId,
        Integer turn,
        String sender,
        String messageText,
        LocalDateTime createdAt
) {
    public static ChatMessageResponse from(ChatHistory chat) {
        return new ChatMessageResponse(
                chat.getChatId(),
                chat.getTurn(),
                chat.getSender(),
                chat.getMessageText(),
                chat.getCreatedAt()
        );
    }
}
