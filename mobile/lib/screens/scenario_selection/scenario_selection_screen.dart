import 'package:flutter/material.dart';

import '../../models/game/chapter.dart';
import '../../models/game/stage.dart';
import '../../services/game_api.dart';
import '../../services/game_progress.dart';
import '../../services/session_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/scenario_card.dart';
import '../login/login_screen.dart';
import '../stage1_sms/sms_screen.dart';

class _ChapterWithStages {
  const _ChapterWithStages(this.chapter, this.stages);

  final Chapter chapter;
  final List<Stage> stages;
}

class ScenarioSelectionScreen extends StatefulWidget {
  const ScenarioSelectionScreen({super.key});

  @override
  State<ScenarioSelectionScreen> createState() =>
      _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen> {
  late Future<List<_ChapterWithStages>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadChaptersWithStages();
    GameProgress.instance.syncFromServer();
  }

  Future<List<_ChapterWithStages>> _loadChaptersWithStages() async {
    final chapters = await GameApi.getChapters();
    chapters.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final stageLists = await Future.wait(
      chapters.map((chapter) => GameApi.getStages(chapter.chapterId)),
    );

    return [
      for (var i = 0; i < chapters.length; i++)
        _ChapterWithStages(chapters[i], stageLists[i]),
    ];
  }

  void _retry() {
    setState(() => _future = _loadChaptersWithStages());
  }

  void _onStageSelected(Stage stage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SmsScreen(stage: stage)),
    );
  }

  Future<void> _logout() async {
    await SessionStore.clear();
    if (!mounted) return;
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
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: FutureBuilder<List<_ChapterWithStages>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.alarm),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final chapters = snapshot.data!;
          final totalStages = chapters.fold<int>(
            0,
            (sum, c) => sum + c.stages.length,
          );

          return ListView(
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
              _StatBar(totalStages: totalStages),
              const SizedBox(height: 24),
              for (final entry in chapters) ...[
                Text(entry.chapter.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  entry.chapter.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                if (entry.stages.isEmpty)
                  Text(
                    '준비 중입니다.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  for (final stage in entry.stages) ...[
                    ScenarioCard(
                      stage: stage,
                      onTap: () => _onStageSelected(stage),
                    ),
                    const SizedBox(height: 14),
                  ],
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.alarm,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              '시나리오를 불러오지 못했습니다.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.totalStages});

  final int totalStages;

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
                value: '${progress.completedCount} / $totalStages',
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
