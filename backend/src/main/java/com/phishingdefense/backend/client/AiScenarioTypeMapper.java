package com.phishingdefense.backend.client;

/**
 * 우리 내부 Stage.phishingType(예: smishing_bank, messenger_family)을
 * AI 서버가 이해하는 scenario_type(prosecutor/family/loan/bank/delivery)으로 변환한다.
 * 두 팀의 분류 체계가 아직 통일되어 있지 않아 임시로 키워드 기반 매핑을 사용한다.
 */
public final class AiScenarioTypeMapper {

    private static final String DEFAULT_SCENARIO_TYPE = "bank";

    private AiScenarioTypeMapper() {
    }

    public static String map(String internalPhishingType) {
        if (internalPhishingType == null) {
            return DEFAULT_SCENARIO_TYPE;
        }

        String type = internalPhishingType.toLowerCase();
        if (type.contains("prosecut") || type.contains("voice")) {
            return "prosecutor";
        }
        if (type.contains("family") || type.contains("messenger")) {
            return "family";
        }
        if (type.contains("loan")) {
            return "loan";
        }
        if (type.contains("delivery")) {
            return "delivery";
        }
        if (type.contains("bank") || type.contains("finance") || type.contains("telecom")) {
            return "bank";
        }
        return DEFAULT_SCENARIO_TYPE;
    }
}
