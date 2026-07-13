class JudgmentResult {
  const JudgmentResult({
    required this.isCorrect,
    required this.feedback,
    required this.stageProgression,
  });

  factory JudgmentResult.fromJson(Map<String, dynamic> json) {
    return JudgmentResult(
      isCorrect: json['isCorrect'] as bool,
      feedback: json['feedback'] as String,
      stageProgression: json['stageProgression'] as int,
    );
  }

  final bool isCorrect;
  final String feedback;
  final int stageProgression;
}
