import 'package:flutter/material.dart';

enum ScenarioDifficulty { easy, normal, hard }

enum ChatBranch { comply, suspicious, refusal, verify, angry }

enum EvidenceSource { sms, chat }

class EvidenceItem {
  const EvidenceItem({
    required this.label,
    required this.importance,
    required this.source,
  });

  final String label;
  final int importance; // 1(낮음) ~ 5(매우 중요)
  final EvidenceSource source;
}

/// AI(또는 SMS)가 실제로 한 말 한 줄. [evidenceLabel]이 있으면 사용자가 이 줄을
/// "증거로 저장"했을 때 어떤 [EvidenceItem]에 해당하는지 나타낸다. null이면
/// 실제로는 증거가 되지 않는 대사(정황일 뿐이거나 단순 반응)라는 뜻이다.
class AiLine {
  const AiLine(this.text, {this.evidenceLabel});

  final String text;
  final String? evidenceLabel;
}

class Scenario {
  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.accentColor,
    required this.icon,
    required this.senderName,
    required this.smsContent,
    required this.aiOpener,
    required this.aiResponses,
    required this.aiFallbackResponse,
    required this.aiSuspicionResponses,
    required this.aiRefusalResponses,
    required this.aiVerifyResponses,
    required this.aiAngryResponses,
    required this.isPhishing,
    required this.evidence,
  });

  final String id;
  final String title;
  final String description;
  final ScenarioDifficulty difficulty;
  final Color accentColor;
  final IconData icon;

  final String senderName;
  final String smsContent;
  final AiLine aiOpener;
  final List<AiLine> aiResponses;
  final AiLine aiFallbackResponse;
  final List<String> aiSuspicionResponses;
  final List<String> aiRefusalResponses;
  final List<String> aiVerifyResponses;
  final List<String> aiAngryResponses;

  final bool isPhishing;
  final List<EvidenceItem> evidence;

  List<String> get phishingHints => evidence.map((e) => e.label).toList();

  String _pick(List<String> variants, int turnIndex) {
    final index = turnIndex.clamp(0, variants.length - 1);
    return variants[index];
  }

  String suspicionResponseFor(int turnIndex) =>
      _pick(aiSuspicionResponses, turnIndex);

  String refusalResponseFor(int turnIndex) =>
      _pick(aiRefusalResponses, turnIndex);

  String verifyResponseFor(int turnIndex) =>
      _pick(aiVerifyResponses, turnIndex);

  String angryResponseFor(int turnIndex) => _pick(aiAngryResponses, turnIndex);
}
