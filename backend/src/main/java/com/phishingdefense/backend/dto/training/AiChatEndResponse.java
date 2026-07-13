package com.phishingdefense.backend.dto.training;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * AI 모듈(/ai) {@code POST /chat/end} 응답 스키마를 그대로 미러링한다.
 */
public record AiChatEndResponse(
        @JsonProperty("personal_info_requested") Boolean personalInfoRequested,
        @JsonProperty("account_number_requested") Boolean accountNumberRequested,
        @JsonProperty("money_requested") Boolean moneyRequested,
        @JsonProperty("urgency_created") Boolean urgencyCreated,
        @JsonProperty("authority_impersonation") Boolean authorityImpersonation,
        @JsonProperty("suspicious_link") Boolean suspiciousLink,
        @JsonProperty("user_fell_for_it") Boolean userFellForIt,
        @JsonProperty("risk_score") Integer riskScore,
        @JsonProperty("good_points") String goodPoints,
        @JsonProperty("mistakes") String mistakes,
        @JsonProperty("improvement_tips") String improvementTips
) {
}
