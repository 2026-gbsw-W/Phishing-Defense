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
@Table(name = "scenario_records")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ScenarioRecord {

    public static final int FIRST_STAGE = 1;
    public static final int LAST_STAGE = 6;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "record_id")
    private Long recordId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "chapter_id", nullable = false)
    private Integer chapterId;

    @Column(name = "scenario_id", nullable = false)
    private Long scenarioId;

    @Column(name = "current_stage")
    private Integer currentStage;

    @Column(name = "current_turn")
    private Integer currentTurn;

    @Column(name = "is_correct_judgment")
    private Boolean correctJudgment;

    @Column(name = "judgment_at_turn")
    private Integer judgmentAtTurn;

    @Column(name = "hints_used")
    private Integer hintsUsed;

    @Column(name = "evidence_marked_count")
    private Integer evidenceMarkedCount;

    @Column(name = "evidence_submitted_count")
    private Integer evidenceSubmittedCount;

    @Column(name = "evidence_valid_count")
    private Integer evidenceValidCount;

    @Column(name = "star_rating")
    private Integer starRating;

    @Column(name = "total_score")
    private Integer totalScore;

    @Column(name = "accuracy_score")
    private Integer accuracyScore;

    @Column(name = "evidence_score")
    private Integer evidenceScore;

    @Column(name = "report_handling_score")
    private Integer reportHandlingScore;

    @Column(name = "hint_penalty")
    private Integer hintPenalty;

    @Column(name = "played_at")
    private LocalDateTime playedAt;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column(name = "is_completed")
    private Boolean completed;

    @Column(name = "is_reported")
    private Boolean reported;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;

    @Builder
    private ScenarioRecord(Long userId, Integer chapterId, Long scenarioId, LocalDateTime playedAt) {
        this.userId = userId;
        this.chapterId = chapterId;
        this.scenarioId = scenarioId;
        this.currentStage = FIRST_STAGE;
        this.currentTurn = 0;
        this.hintsUsed = 0;
        this.starRating = 0;
        this.totalScore = 0;
        this.completed = false;
        this.reported = false;
        this.playedAt = playedAt;
    }

    public static ScenarioRecord start(Long userId, Integer chapterId, Long scenarioId) {
        return ScenarioRecord.builder()
                .userId(userId)
                .chapterId(chapterId)
                .scenarioId(scenarioId)
                .playedAt(LocalDateTime.now())
                .build();
    }

    public boolean isOwnedBy(Long userId) {
        return this.userId.equals(userId);
    }

    public boolean isCompleted() {
        return Boolean.TRUE.equals(this.completed);
    }

    public int advanceTurn() {
        this.currentTurn = (this.currentTurn == null ? 0 : this.currentTurn) + 1;
        return this.currentTurn;
    }

    public void useHint() {
        this.hintsUsed = (this.hintsUsed == null ? 0 : this.hintsUsed) + 1;
    }
}
