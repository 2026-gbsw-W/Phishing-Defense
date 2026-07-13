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
 * PRD상 "시나리오(scenario)"에 해당하는 테이블을 매핑한다.
 * 게임 내 용어로는 챕터 하위의 "스테이지"로 취급한다.
 */
@Entity
@Table(name = "scenarios")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Stage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "scenario_id")
    private Long stageId;

    @Column(name = "chapter_id", nullable = false)
    private Integer chapterId;

    @Column(name = "title")
    private String title;

    @Column(name = "initial_message")
    private String initialMessage;

    @Column(name = "phishing_type")
    private String phishingType;

    @Column(name = "is_phishing")
    private Boolean phishing;

    @Column(name = "required_evidence", columnDefinition = "JSON")
    private String requiredEvidence;

    @Column(name = "difficulty")
    private Integer difficulty;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}
