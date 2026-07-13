package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * AI 모듈의 POST /evidence 응답을 그대로 저장한다 (training_sessions 1:N).
 */
@Entity
@Table(name = "training_evidence")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TrainingEvidence {

    @Id
    @Column(name = "evidence_id", length = 36)
    private String evidenceId;

    @Column(name = "session_id", nullable = false)
    private String sessionId;

    @Column(name = "speaker", nullable = false)
    private String speaker;

    @Column(name = "message", columnDefinition = "TEXT", nullable = false)
    private String message;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private TrainingEvidence(String evidenceId, String sessionId, String speaker, String message) {
        this.evidenceId = evidenceId;
        this.sessionId = sessionId;
        this.speaker = speaker;
        this.message = message;
    }

    public static TrainingEvidence of(String evidenceId, String sessionId, String speaker, String message) {
        return TrainingEvidence.builder()
                .evidenceId(evidenceId)
                .sessionId(sessionId)
                .speaker(speaker)
                .message(message)
                .build();
    }
}
