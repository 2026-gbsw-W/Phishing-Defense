class ReportClaimResult {
  const ReportClaimResult({
    required this.xpAdded,
    required this.levelUp,
    required this.newBalance,
  });

  factory ReportClaimResult.fromJson(Map<String, dynamic> json) {
    return ReportClaimResult(
      xpAdded: json['xpAdded'] as int,
      levelUp: json['levelUp'] as bool,
      newBalance: json['newBalance'] as int,
    );
  }

  final int xpAdded;
  final bool levelUp;
  final int newBalance;
}
