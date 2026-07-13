class ScenarioStart {
  const ScenarioStart({required this.recordId, required this.initialMessage});

  factory ScenarioStart.fromJson(Map<String, dynamic> json) {
    return ScenarioStart(
      recordId: json['recordId'] as int,
      initialMessage: json['initialMessage'] as String,
    );
  }

  final int recordId;
  final String initialMessage;
}
