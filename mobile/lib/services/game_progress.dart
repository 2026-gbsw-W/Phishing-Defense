import 'package:flutter/foundation.dart';

import '../logic/level_system.dart';
import 'game_api.dart';

class GameProgress extends ChangeNotifier {
  GameProgress._();

  static final GameProgress instance = GameProgress._();

  int totalXp = 0;
  int completedCount = 0;
  int? _serverLevel;

  int get level => _serverLevel ?? LevelSystem.levelForXp(totalXp);
  String get levelLabel => LevelSystem.labelForXp(totalXp);

  /// 서버에 실제로 저장된 레벨/XP/완료 횟수를 불러와 반영한다. 로그인 직후나
  /// 시나리오 완료 후(리포트 클레임 이후)에 호출해 기기 재시작으로 값이
  /// 초기화되지 않도록 한다.
  Future<void> syncFromServer() async {
    try {
      final profile = await GameApi.getMyProfile();
      final stats = await GameApi.getMyStatistics();
      totalXp = profile.totalXp;
      _serverLevel = profile.level;
      completedCount = stats.totalPlays;
      notifyListeners();
    } catch (_) {
      // 네트워크 오류 시 기존에 표시되던 값을 그대로 유지한다.
    }
  }
}
