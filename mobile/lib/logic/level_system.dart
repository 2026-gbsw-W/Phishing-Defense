class _LevelMilestone {
  const _LevelMilestone(this.level, this.xp, this.name);
  final int level;
  final int xp;
  final String name;
}

const _milestones = [
  _LevelMilestone(1, 0, '시민'),
  _LevelMilestone(5, 4000, '예비 수사관'),
  _LevelMilestone(10, 10000, '수사관'),
  _LevelMilestone(15, 18000, '중급 수사관'),
  _LevelMilestone(20, 28000, '특별 수사관'),
  _LevelMilestone(25, 40000, '고급 수사관'),
  _LevelMilestone(30, 60000, '피싱 헌터'),
];

class LevelSystem {
  LevelSystem._();

  static int levelForXp(int totalXp) {
    if (totalXp >= _milestones.last.xp) {
      final beyond = totalXp - _milestones.last.xp;
      return _milestones.last.level + (beyond ~/ 10000);
    }

    for (var i = _milestones.length - 1; i >= 0; i--) {
      final current = _milestones[i];
      if (totalXp < current.xp) continue;

      if (i == _milestones.length - 1) return current.level;

      final next = _milestones[i + 1];
      final progress = (totalXp - current.xp) / (next.xp - current.xp);
      return current.level + ((next.level - current.level) * progress).floor();
    }

    return _milestones.first.level;
  }

  static String labelForXp(int totalXp) {
    var label = _milestones.first.name;
    for (final m in _milestones) {
      if (totalXp >= m.xp) label = m.name;
    }
    if (levelForXp(totalXp) > _milestones.last.level) {
      return '전설의 헌터';
    }
    return label;
  }
}
