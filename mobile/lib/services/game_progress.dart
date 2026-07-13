import 'package:flutter/foundation.dart';

import '../logic/level_system.dart';

class GameProgress extends ChangeNotifier {
  GameProgress._();

  static final GameProgress instance = GameProgress._();

  int totalXp = 0;
  final Set<String> completedScenarioIds = {};

  int get level => LevelSystem.levelForXp(totalXp);
  String get levelLabel => LevelSystem.labelForXp(totalXp);
  int get completedCount => completedScenarioIds.length;

  void recordCompletion({required String scenarioId, required int xpEarned}) {
    totalXp += xpEarned;
    completedScenarioIds.add(scenarioId);
    notifyListeners();
  }
}
