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

/**
 * "피싱 도감" - 사용자가 플레이하여 수집한 피싱 유형(스테이지)을 기록한다.
 * docs에는 명시적 스키마가 없어 IA상의 기능 설명을 근거로 설계했다.
 */
@Entity
@Table(name = "phishing_index")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PhishingIndexEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "phishing_index_id")
    private Long phishingIndexId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "chapter_id", nullable = false)
    private Integer chapterId;

    @Column(name = "scenario_id", nullable = false)
    private Long scenarioId;

    @Column(name = "collected_at", insertable = false, updatable = false)
    private LocalDateTime collectedAt;
}
