import 'package:flutter/material.dart';

import '../../models/scenario.dart';
import '../../models/scenario_data.dart';
import '../../services/game_progress.dart';
import '../../services/session_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scenario_card.dart';
import '../login/login_screen.dart';
import '../stage1_sms/sms_screen.dart';

class ScenarioSelectionScreen extends StatelessWidget {
  const ScenarioSelectionScreen({super.key});

  void _onScenarioSelected(BuildContext context, Scenario scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SmsScreen(scenario: scenario)),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await SessionStore.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('피싱 디펜스'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            '01 시나리오 선택',
            style: textTheme.labelMedium?.copyWith(color: AppColors.alarm),
          ),
          const SizedBox(height: 8),
          Text('어떤 상황을 훈련해볼까요?', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '실제 사례를 바탕으로 AI가 사기꾼처럼 전화/채팅합니다.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _StatBar(),
          const SizedBox(height: 24),
          for (final scenario in demoScenarios) ...[
            ScenarioCard(
              scenario: scenario,
              onTap: () => _onScenarioSelected(context, scenario),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgress.instance,
      builder: (context, _) {
        final progress = GameProgress.instance;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: '레벨',
                value: 'Lv.${progress.level}',
                color: AppColors.alarm,
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              _StatItem(
                label: '총 XP',
                value: '${progress.totalXp}',
                color: AppColors.textPrimary,
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              _StatItem(
                label: '완료',
                value: '${progress.completedCount} / ${demoScenarios.length}',
                color: AppColors.textPrimary,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: AppTheme.mono(textTheme.titleLarge?.copyWith(color: color)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
