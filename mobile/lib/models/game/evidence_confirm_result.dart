import 'evidence_item.dart';

class EvidenceConfirmResult {
  const EvidenceConfirmResult({
    required this.evidenceCollectionPercentage,
    required this.missedEvidence,
  });

  factory EvidenceConfirmResult.fromJson(Map<String, dynamic> json) {
    return EvidenceConfirmResult(
      evidenceCollectionPercentage: json['evidenceCollectionPercentage'] as int,
      missedEvidence: (json['missedEvidence'] as List<dynamic>? ?? [])
          .map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int evidenceCollectionPercentage;
  final List<EvidenceItem> missedEvidence;
}
