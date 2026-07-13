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

class ScenarioReport {
  const ScenarioReport({
    required this.accuracyScore,
    required this.starRating,
    required this.xpEarned,
    required this.detailedFeedback,
    required this.evidenceAnalysis,
    required this.recommendations,
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
    );
  }

  final int accuracyScore;
  final int starRating;
  final int xpEarned;
  final String detailedFeedback;
  final EvidenceAnalysis evidenceAnalysis;
  final List<String> recommendations;
}
