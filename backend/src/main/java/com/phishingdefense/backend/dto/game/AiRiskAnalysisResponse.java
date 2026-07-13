package com.phishingdefense.backend.dto.game;

import com.phishingdefense.backend.entity.TrainingResult;
import java.util.List;

public record AiRiskAnalysisResponse(
        Integer riskScore,
        Boolean personalInfoRequested,
        Boolean accountNumberRequested,
        Boolean moneyRequested,
        Boolean urgencyCreated,
        Boolean authorityImpersonation,
        Boolean suspiciousLink,
        Boolean userFellForIt,
        List<String> dangerousMessages,
        String evidenceFeedback,
        String goodPoints,
        String mistakes,
        String improvementTips
) {
    public static AiRiskAnalysisResponse from(TrainingResult result) {
        return new AiRiskAnalysisResponse(
                result.getRiskScore(),
                result.getPersonalInfoRequested(),
                result.getAccountNumberRequested(),
                result.getMoneyRequested(),
                result.getUrgencyCreated(),
                result.getAuthorityImpersonation(),
                result.getSuspiciousLink(),
                result.getUserFellForIt(),
                result.getDangerousMessages(),
                result.getEvidenceFeedback(),
                result.getGoodPoints(),
                result.getMistakes(),
                result.getImprovementTips()
        );
    }
}
