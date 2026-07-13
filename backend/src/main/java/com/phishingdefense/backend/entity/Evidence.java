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
@Table(name = "evidence")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Evidence {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "evidence_id")
    private Long evidenceId;

    @Column(name = "record_id", nullable = false)
    private Long recordId;

    @Column(name = "evidence_type")
    private String evidenceType;

    @Column(name = "evidence_value")
    private String evidenceValue;

    @Column(name = "message_turn")
    private Integer messageTurn;

    @Column(name = "is_submitted_at_report")
    private Boolean submittedAtReport;

    @Column(name = "is_valid_evidence")
    private Boolean validEvidence;

    @Column(name = "validity_reason")
    private String validityReason;

    @Column(name = "importance_level")
    private Integer importanceLevel;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}
