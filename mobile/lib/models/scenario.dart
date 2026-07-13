import 'package:flutter/material.dart';

enum ScenarioDifficulty { easy, normal, hard }

class EvidenceItem {
  const EvidenceItem({required this.label, required this.importance});

  final String label;
  final int importance; // 1(낮음) ~ 5(매우 중요)
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
    required this.aiSuspicionResponse,
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
  final String aiOpener;
  final List<String> aiResponses;
  final String aiFallbackResponse;
  final String aiSuspicionResponse;

  final bool isPhishing;
  final List<EvidenceItem> evidence;

  List<String> get phishingHints => evidence.map((e) => e.label).toList();
}
