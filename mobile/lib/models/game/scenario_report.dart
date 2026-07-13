import 'evidence_item.dart';

class EvidenceAnalysis {
  const EvidenceAnalysis({
    required this.submittedCount,
    required this.totalCount,
    required this.missedEvidence,
  });

  factory EvidenceAnalysis.fromJson(Map<String, dynamic> json) {
    return EvidenceAnalysis(
      submittedCount: json['submittedCount'] as int,
      totalCount: json['totalCount'] as int,
      missedEvidence: (json['missedEvidence'] as List<dynamic>? ?? [])
          .map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int submittedCount;
  final int totalCount;
  final List<EvidenceItem> missedEvidence;
}

class AiRiskAnalysis {
  const AiRiskAnalysis({
    required this.riskScore,
    required this.goodPoints,
    required this.mistakes,
    required this.improvementTips,
    required this.dangerousMessages,
    required this.personalInfoRequested,
    required this.accountNumberRequested,
    required this.moneyRequested,
    required this.urgencyCreated,
    required this.authorityImpersonation,
    required this.suspiciousLink,
    required this.userFellForIt,
    required this.evidenceFeedback,
  });

  factory AiRiskAnalysis.fromJson(Map<String, dynamic> json) {
    return AiRiskAnalysis(
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
      goodPoints: json['goodPoints'] as String? ?? '',
      mistakes: json['mistakes'] as String? ?? '',
      improvementTips: json['improvementTips'] as String? ?? '',
      dangerousMessages: (json['dangerousMessages'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      personalInfoRequested: json['personalInfoRequested'] as bool? ?? false,
      accountNumberRequested: json['accountNumberRequested'] as bool? ?? false,
      moneyRequested: json['moneyRequested'] as bool? ?? false,
      urgencyCreated: json['urgencyCreated'] as bool? ?? false,
      authorityImpersonation: json['authorityImpersonation'] as bool? ?? false,
      suspiciousLink: json['suspiciousLink'] as bool? ?? false,
      userFellForIt: json['userFellForIt'] as bool? ?? false,
      evidenceFeedback: json['evidenceFeedback'] as String? ?? '',
    );
  }

  final int riskScore;
  final String goodPoints;
  final String mistakes;
  final String improvementTips;
  final List<String> dangerousMessages;
  final bool personalInfoRequested;
  final bool accountNumberRequested;
  final bool moneyRequested;
  final bool urgencyCreated;
  final bool authorityImpersonation;
  final bool suspiciousLink;
  final bool userFellForIt;
  final String evidenceFeedback;
}

class ScenarioReport {
  const ScenarioReport({
    required this.accuracyScore,
    required this.starRating,
    required this.xpEarned,
    required this.detailedFeedback,
    required this.evidenceAnalysis,
    required this.recommendations,
    this.aiAnalysis,
  });

  factory ScenarioReport.fromJson(Map<String, dynamic> json) {
    return ScenarioReport(
      accuracyScore: json['accuracyScore'] as int,
      starRating: json['starRating'] as int,
      xpEarned: json['xpEarned'] as int,
      detailedFeedback: json['detailedFeedback'] as String,
      evidenceAnalysis: EvidenceAnalysis.fromJson(
        json['evidenceAnalysis'] as Map<String, dynamic>,
      ),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      aiAnalysis: json['aiAnalysis'] == null
          ? null
          : AiRiskAnalysis.fromJson(json['aiAnalysis'] as Map<String, dynamic>),
    );
  }

  final int accuracyScore;
  final int starRating;
  final int xpEarned;
  final String detailedFeedback;
  final EvidenceAnalysis evidenceAnalysis;
  final List<String> recommendations;
  final AiRiskAnalysis? aiAnalysis;
}
