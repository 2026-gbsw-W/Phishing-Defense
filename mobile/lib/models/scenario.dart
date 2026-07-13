import 'package:flutter/material.dart';

enum ScenarioDifficulty { easy, normal, hard }

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
    required this.phishingHints,
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
  final List<String> phishingHints;
}
