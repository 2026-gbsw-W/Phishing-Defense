import 'package:flutter/foundation.dart';

/// 사용자가 대화 중 직접 "증거로 저장"한 한 건.
///
/// [matchedLabel]은 시나리오의 실제 증거 카탈로그(EvidenceItem.label)와
/// 일치하면 채워지고, 사용자가 증거가 아닌 대사를 저장했다면 null이다.
/// 최종 유효/무효 판정(Stage 6)은 이 값의 유무로 결정한다.
class SavedEvidence {
  const SavedEvidence({required this.sourceText, required this.matchedLabel});

  final String sourceText;
  final String? matchedLabel;

  bool get isValid => matchedLabel != null;
}

/// 한 시나리오 플레이 동안(Stage 1~6) 사용자가 저장한 증거를 들고 다니는 그릇.
///
/// 시나리오를 시작할 때마다 새로 만들어 SmsScreen부터 ResultScreen까지
/// 값으로 전달한다(전역 싱글턴이 아님 — 플레이마다 독립적이어야 하므로).
class EvidenceCollector extends ChangeNotifier {
  final List<SavedEvidence> _saved = [];
  final Set<String> _submittedSourceTexts = {};

  List<SavedEvidence> get saved => List.unmodifiable(_saved);

  bool isSaved(String sourceText) =>
      _saved.any((e) => e.sourceText == sourceText);

  void save(SavedEvidence evidence) {
    if (isSaved(evidence.sourceText)) return;
    _saved.add(evidence);
    notifyListeners();
  }

  void remove(String sourceText) {
    _saved.removeWhere((e) => e.sourceText == sourceText);
    _submittedSourceTexts.remove(sourceText);
    notifyListeners();
  }

  Set<String> get submittedSourceTexts =>
      Set.unmodifiable(_submittedSourceTexts);

  void setSubmitted(String sourceText, bool submitted) {
    if (submitted) {
      _submittedSourceTexts.add(sourceText);
    } else {
      _submittedSourceTexts.remove(sourceText);
    }
    notifyListeners();
  }

  List<SavedEvidence> get submittedEvidence => _saved
      .where((e) => _submittedSourceTexts.contains(e.sourceText))
      .toList();
}
