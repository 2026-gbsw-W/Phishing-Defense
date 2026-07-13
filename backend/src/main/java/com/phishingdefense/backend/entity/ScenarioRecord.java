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
@Table(name = "scenario_records")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ScenarioRecord {

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
}
