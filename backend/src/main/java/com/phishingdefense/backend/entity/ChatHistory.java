package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "chat_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ChatHistory {

    public static final String SENDER_USER = "user";
    public static final String SENDER_AI = "ai";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "chat_id")
    private Long chatId;

    @Column(name = "record_id", nullable = false)
    private Long recordId;

    @Column(name = "turn")
    private Integer turn;

    @Column(name = "sender")
    private String sender;

    @Column(name = "message_text", columnDefinition = "LONGTEXT")
    private String messageText;

    @Column(name = "ai_model")
    private String aiModel;

    @Column(name = "model_version")
    private String modelVersion;

    @Column(name = "tokens_used")
    private Integer tokensUsed;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private ChatHistory(Long recordId, Integer turn, String sender, String messageText,
                         String aiModel, String modelVersion) {
        this.recordId = recordId;
        this.turn = turn;
        this.sender = sender;
        this.messageText = messageText;
        this.aiModel = aiModel;
        this.modelVersion = modelVersion;
    }

    public static ChatHistory userMessage(Long recordId, Integer turn, String messageText) {
        return ChatHistory.builder()
                .recordId(recordId)
                .turn(turn)
                .sender(SENDER_USER)
                .messageText(messageText)
                .build();
    }

    public static ChatHistory aiMessage(Long recordId, Integer turn, String messageText,
                                         String aiModel, String modelVersion) {
        return ChatHistory.builder()
                .recordId(recordId)
                .turn(turn)
                .sender(SENDER_AI)
                .messageText(messageText)
                .aiModel(aiModel)
                .modelVersion(modelVersion)
                .build();
    }
}
