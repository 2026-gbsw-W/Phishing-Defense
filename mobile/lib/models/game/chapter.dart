class Chapter {
  const Chapter({
    required this.chapterId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.scenarioCount,
    required this.orderIndex,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      scenarioCount: json['scenarioCount'] as int,
      orderIndex: json['orderIndex'] as int,
    );
  }

  final int chapterId;
  final String title;
  final String description;
  final int difficulty;
  final int scenarioCount;
  final int orderIndex;
}
