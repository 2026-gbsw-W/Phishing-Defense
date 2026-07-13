package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "daily_missions")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class DailyMission {

    public static final String TYPE_FIXED = "fixed";
    public static final String TYPE_DYNAMIC = "dynamic";
    public static final String TYPE_BONUS = "bonus";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mission_id")
    private Long missionId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "mission_type", nullable = false)
    private String missionType;

    @Column(name = "mission_description", nullable = false)
    private String missionDescription;

    @Column(name = "recommendation_reason")
    private String recommendationReason;

    @Column(name = "is_completed")
    private Boolean completed;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "reward_xp")
    private Integer rewardXp;

    @Column(name = "created_date", nullable = false)
    private LocalDate createdDate;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private DailyMission(Long userId, String missionType, String missionDescription,
                          String recommendationReason, Integer rewardXp, LocalDate createdDate) {
        this.userId = userId;
        this.missionType = missionType;
        this.missionDescription = missionDescription;
        this.recommendationReason = recommendationReason;
        this.rewardXp = rewardXp;
        this.createdDate = createdDate;
        this.completed = false;
    }

    public static DailyMission create(Long userId, String missionType, String missionDescription,
                                       String recommendationReason, Integer rewardXp, LocalDate createdDate) {
        return DailyMission.builder()
                .userId(userId)
                .missionType(missionType)
                .missionDescription(missionDescription)
                .recommendationReason(recommendationReason)
                .rewardXp(rewardXp)
                .createdDate(createdDate)
                .build();
    }

    public void complete() {
        this.completed = true;
        this.completedAt = LocalDateTime.now();
    }

    public boolean isOwnedBy(Long userId) {
        return this.userId.equals(userId);
    }
}
