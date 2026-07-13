package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "chat_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ChatHistory {

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
}
