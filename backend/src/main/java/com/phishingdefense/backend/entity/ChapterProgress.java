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
@Table(name = "chapter_progress")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ChapterProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "progress_id")
    private Long progressId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "chapter_id", nullable = false)
    private Integer chapterId;

    @Column(name = "is_completed")
    private Boolean completed;

    @Column(name = "best_star")
    private Integer bestStar;

    @Column(name = "total_attempts")
    private Integer totalAttempts;

    @Column(name = "first_clear_at")
    private LocalDateTime firstClearAt;

    @Column(name = "last_attempt_at")
    private LocalDateTime lastAttemptAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;
}
