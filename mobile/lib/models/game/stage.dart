class Stage {
  const Stage({
    required this.stageId,
    required this.chapterId,
    required this.title,
    required this.initialMessage,
    required this.phishingType,
    required this.difficulty,
    required this.completed,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      stageId: json['stageId'] as int,
      chapterId: json['chapterId'] as int,
      title: json['title'] as String,
      initialMessage: json['initialMessage'] as String,
      phishingType: json['phishingType'] as String? ?? 'unknown',
      difficulty: json['difficulty'] as int? ?? 1,
      completed: json['completed'] as bool? ?? false,
    );
  }

  final int stageId;
  final int chapterId;
  final String title;
  final String initialMessage;
  final String phishingType;
  final int difficulty;
  final bool completed;

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return '쉬움';
      case 2:
        return '보통';
      default:
        return '어려움';
    }
  }
}
