class EvidenceItem {
  const EvidenceItem({
    required this.evidenceId,
    required this.type,
    required this.value,
    required this.importance,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      evidenceId: json['evidenceId'] as int,
      type: json['type'] as String,
      value: json['value'] as String,
      importance: json['importance'] as int,
    );
  }

  final int evidenceId;
  final String type;
  final String value;
  final int importance;
}
