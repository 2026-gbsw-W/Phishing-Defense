class ScoreBreakdown {
  const ScoreBreakdown({
    required this.accuracyScore,
    required this.evidenceScore,
    required this.reportScore,
    required this.totalScore,
    required this.starRating,
    required this.baseXp,
    required this.starBonusXp,
    required this.evidenceBonusXp,
    required this.reportBonusXp,
    required this.totalXp,
  });

  final int accuracyScore;
  final int evidenceScore;
  final int reportScore;
  final int totalScore;
  final int starRating; // 0~3

  final int baseXp;
  final int starBonusXp;
  final int evidenceBonusXp;
  final int reportBonusXp;
  final int totalXp;
}

int _judgmentComponentFor({required bool judgedCorrectly, required int judgmentTurn}) {
  if (!judgedCorrectly) return 15;
  if (judgmentTurn <= 2) return 30;
  if (judgmentTurn <= 4) return 25;
  return 20;
}

int _evidenceScoreFor(int percentage) {
  if (percentage >= 100) return 20;
  if (percentage >= 90) return 18;
  if (percentage >= 80) return 15;
  if (percentage >= 70) return 10;
  return 5;
}

int _reportScoreFor(int reportHandledCount) {
  switch (reportHandledCount) {
    case 2:
      return 20;
    case 1:
      return 15;
    default:
      return 10;
  }
}

int _starRatingFor(int totalScore) {
  if (totalScore >= 90) return 3;
  if (totalScore >= 80) return 2;
  if (totalScore >= 60) return 1;
  return 0;
}

int _starBonusXpFor(int starRating) {
  switch (starRating) {
    case 3:
      return 70;
    case 2:
      return 30;
    case 1:
      return 10;
    default:
      return 0;
  }
}

ScoreBreakdown calculateScore({
  required bool judgedCorrectly,
  required int judgmentTurn,
  required int evidenceCollectedPercentage,
  required int reportHandledCount,
}) {
  const responseQualityScore = 20;
  final judgmentComponent = _judgmentComponentFor(
    judgedCorrectly: judgedCorrectly,
    judgmentTurn: judgmentTurn,
  );
  final accuracyScore = judgmentComponent + responseQualityScore;
  final evidenceScore = _evidenceScoreFor(evidenceCollectedPercentage);
  final reportScore = _reportScoreFor(reportHandledCount);

  final totalScore =
      (accuracyScore + evidenceScore + reportScore).clamp(0, 100);
  final starRating = _starRatingFor(totalScore);

  const baseXp = 150;
  final starBonusXp = _starBonusXpFor(starRating);
  final evidenceBonusXp = evidenceCollectedPercentage >= 100 ? 40 : 0;
  final reportBonusXp = reportHandledCount >= 2 ? 50 : 0;

  final totalXp = baseXp + starBonusXp + evidenceBonusXp + reportBonusXp;

  return ScoreBreakdown(
    accuracyScore: accuracyScore,
    evidenceScore: evidenceScore,
    reportScore: reportScore,
    totalScore: totalScore,
    starRating: starRating,
    baseXp: baseXp,
    starBonusXp: starBonusXp,
    evidenceBonusXp: evidenceBonusXp,
    reportBonusXp: reportBonusXp,
    totalXp: totalXp,
  );
}
