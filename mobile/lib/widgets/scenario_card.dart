import 'package:flutter/material.dart';

import '../models/scenario.dart';
import '../theme/app_colors.dart';

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({super.key, required this.scenario, required this.onTap});

  final Scenario scenario;
  final VoidCallback onTap;

  String _difficultyLabel(ScenarioDifficulty difficulty) {
    switch (difficulty) {
      case ScenarioDifficulty.easy:
        return '쉬움';
      case ScenarioDifficulty.normal:
        return '보통';
      case ScenarioDifficulty.hard:
        return '어려움';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.alarm.withValues(alpha: 0.6),
              width: 2,
            ),
            left: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.alarm.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(scenario.icon, color: AppColors.alarm, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scenario.title, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        scenario.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scenario.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '난이도 · ${_difficultyLabel(scenario.difficulty)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scenario.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
