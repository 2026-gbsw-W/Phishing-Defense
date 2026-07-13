class UserStatistics {
  const UserStatistics({required this.totalPlays});

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(totalPlays: json['totalPlays'] as int);
  }

  final int totalPlays;
}
