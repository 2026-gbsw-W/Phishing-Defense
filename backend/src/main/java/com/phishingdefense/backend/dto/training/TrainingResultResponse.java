package com.phishingdefense.backend.dto.training;

import com.phishingdefense.backend.entity.TrainingResult;

public record TrainingResultResponse(
        String sessionId,
        Boolean personalInfoRequested,
        Boolean accountNumberRequested,
        Boolean moneyRequested,
        Boolean urgencyCreated,
        Boolean authorityImpersonation,
        Boolean suspiciousLink,
        Boolean userFellForIt,
        Integer riskScore,
        String goodPoints,
        String mistakes,
        String improvementTips
) {
    public static TrainingResultResponse from(TrainingResult result) {
        return new TrainingResultResponse(
                result.getSessionId(),
                result.getPersonalInfoRequested(),
                result.getAccountNumberRequested(),
                result.getMoneyRequested(),
                result.getUrgencyCreated(),
                result.getAuthorityImpersonation(),
                result.getSuspiciousLink(),
                result.getUserFellForIt(),
                result.getRiskScore(),
                result.getGoodPoints(),
                result.getMistakes(),
                result.getImprovementTips()
        );
    }
}
