package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "chapters")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Chapter {

    @Id
    @Column(name = "chapter_id")
    private Integer chapterId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description")
    private String description;

    @Column(name = "difficulty")
    private Integer difficulty;

    @Column(name = "scenario_count")
    private Integer scenarioCount;

    @Column(name = "order_index")
    private Integer orderIndex;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}
