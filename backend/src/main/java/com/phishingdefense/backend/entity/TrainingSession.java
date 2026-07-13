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
 * AI 모듈(/ai)이 발급하는 session_id(UUID)와 그 세션이 속한 게임 플레이 기록을 연결한다.
 * AI 서버는 세션 데이터를 메모리에만 보관하므로, 여기서 영구 저장한다.
 */
@Entity
@Table(name = "training_sessions")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TrainingSession {

    @Id
    @Column(name = "session_id", length = 36)
    private String sessionId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "record_id", nullable = false)
    private Long recordId;

    @Column(name = "scenario_type", nullable = false)
    private String scenarioType;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private TrainingSession(String sessionId, Long userId, Long recordId, String scenarioType) {
        this.sessionId = sessionId;
        this.userId = userId;
        this.recordId = recordId;
        this.scenarioType = scenarioType;
    }

    public static TrainingSession create(String sessionId, Long userId, Long recordId, String scenarioType) {
        return TrainingSession.builder()
                .sessionId(sessionId)
                .userId(userId)
                .recordId(recordId)
                .scenarioType(scenarioType)
                .build();
    }
}
