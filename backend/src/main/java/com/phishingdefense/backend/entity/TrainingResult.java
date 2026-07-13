package com.phishingdefense.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * AI 모듈의 POST /chat/end 응답을 그대로 저장한다 (training_sessions와 1:1).
 */
@Entity
@Table(name = "training_results")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TrainingResult {

    @Id
    @Column(name = "session_id", length = 36)
    private String sessionId;

    @Column(name = "personal_info_requested")
    private Boolean personalInfoRequested;

    @Column(name = "account_number_requested")
    private Boolean accountNumberRequested;

    @Column(name = "money_requested")
    private Boolean moneyRequested;

    @Column(name = "urgency_created")
    private Boolean urgencyCreated;

    @Column(name = "authority_impersonation")
    private Boolean authorityImpersonation;

    @Column(name = "suspicious_link")
    private Boolean suspiciousLink;

    @Column(name = "user_fell_for_it")
    private Boolean userFellForIt;

    @Column(name = "risk_score")
    private Integer riskScore;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "dangerous_messages", columnDefinition = "JSON")
    private List<String> dangerousMessages;

    @Column(name = "evidence_feedback", columnDefinition = "TEXT")
    private String evidenceFeedback;

    @Column(name = "good_points", columnDefinition = "TEXT")
    private String goodPoints;

    @Column(name = "mistakes", columnDefinition = "TEXT")
    private String mistakes;

    @Column(name = "improvement_tips", columnDefinition = "TEXT")
    private String improvementTips;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private TrainingResult(String sessionId, Boolean personalInfoRequested, Boolean accountNumberRequested,
                            Boolean moneyRequested, Boolean urgencyCreated, Boolean authorityImpersonation,
                            Boolean suspiciousLink, Boolean userFellForIt, Integer riskScore,
                            List<String> dangerousMessages, String evidenceFeedback,
                            String goodPoints, String mistakes, String improvementTips) {
        this.sessionId = sessionId;
        this.personalInfoRequested = personalInfoRequested;
        this.accountNumberRequested = accountNumberRequested;
        this.moneyRequested = moneyRequested;
        this.urgencyCreated = urgencyCreated;
        this.authorityImpersonation = authorityImpersonation;
        this.suspiciousLink = suspiciousLink;
        this.userFellForIt = userFellForIt;
        this.riskScore = riskScore;
        this.dangerousMessages = dangerousMessages;
        this.evidenceFeedback = evidenceFeedback;
        this.goodPoints = goodPoints;
        this.mistakes = mistakes;
        this.improvementTips = improvementTips;
    }

    public static TrainingResult record(String sessionId, Boolean personalInfoRequested,
                                         Boolean accountNumberRequested, Boolean moneyRequested,
                                         Boolean urgencyCreated, Boolean authorityImpersonation,
                                         Boolean suspiciousLink, Boolean userFellForIt, Integer riskScore,
                                         List<String> dangerousMessages, String evidenceFeedback,
                                         String goodPoints, String mistakes, String improvementTips) {
        return TrainingResult.builder()
                .sessionId(sessionId)
                .personalInfoRequested(personalInfoRequested)
                .accountNumberRequested(accountNumberRequested)
                .moneyRequested(moneyRequested)
                .urgencyCreated(urgencyCreated)
                .authorityImpersonation(authorityImpersonation)
                .suspiciousLink(suspiciousLink)
                .userFellForIt(userFellForIt)
                .riskScore(riskScore)
                .dangerousMessages(dangerousMessages)
                .evidenceFeedback(evidenceFeedback)
                .goodPoints(goodPoints)
                .mistakes(mistakes)
                .improvementTips(improvementTips)
                .build();
    }
}
