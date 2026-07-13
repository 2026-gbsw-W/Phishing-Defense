class UserProfile {
  const UserProfile({
    required this.userId,
    required this.level,
    required this.currentXp,
    required this.totalXp,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as int,
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      totalXp: json['totalXp'] as int,
    );
  }

  final int userId;
  final int level;
  final int currentXp;
  final int totalXp;
}
