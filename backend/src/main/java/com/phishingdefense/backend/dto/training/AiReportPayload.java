package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * AI 모듈(/ai) {@code POST /chat/end} 응답의 report 필드를 그대로 미러링한다.
 */
public record AiReportPayload(
        @JsonProperty("personal_info_requested") Boolean personalInfoRequested,
        @JsonProperty("account_number_requested") Boolean accountNumberRequested,
        @JsonProperty("money_requested") Boolean moneyRequested,
        @JsonProperty("urgency_created") Boolean urgencyCreated,
        @JsonProperty("authority_impersonation") Boolean authorityImpersonation,
        @JsonProperty("suspicious_link") Boolean suspiciousLink,
        @JsonProperty("user_fell_for_it") Boolean userFellForIt,
        @JsonProperty("risk_score") Integer riskScore,
        @JsonProperty("dangerous_messages") List<String> dangerousMessages,
        @JsonProperty("evidence_feedback") String evidenceFeedback,
        @JsonProperty("good_points") String goodPoints,
        @JsonProperty("mistakes") String mistakes,
        @JsonProperty("improvement_tips") String improvementTips,
        @JsonProperty("created_at") String createdAt
) {
}
