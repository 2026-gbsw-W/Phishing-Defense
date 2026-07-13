import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../models/game/scenario_report.dart';
import '../../services/game_api.dart';
import '../../services/game_progress.dart';
import '../../theme/app_colors.dart';
import '../scenario_selection/scenario_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.recordId});

  final int recordId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  late Future<ScenarioReport> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadReport();

    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
  }

  Future<ScenarioReport> _loadReport() async {
    final report = await GameApi.getReport(widget.recordId);

    try {
      final claim = await GameApi.claimReport(widget.recordId);
      GameProgress.instance.recordCompletion(
        scenarioId: widget.recordId.toString(),
        xpEarned: claim.xpAdded,
      );
    } catch (_) {
      // 이미 보상을 수령한 플레이(재방문 등)일 수 있다 — 리포트 표시는 계속 진행한다.
    }

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _scaleCtrl.forward();
          if (report.starRating >= 2) _confetti.play();
        }
      });
    }

    return report;
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _backToList() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ScenarioSelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 6 · 결과 리포트'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StageProgressBar(current: 6, total: 6),
        ),
      ),
      body: FutureBuilder<ScenarioReport>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.alarm),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.alarm),
              ),
            );
          }

          final report = snapshot.data!;

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: pi / 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  colors: const [
                    AppColors.amber,
                    AppColors.safe,
                    AppColors.alarm,
                    Colors.white,
                  ],
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: _ScoreBadge(report: report),
                      ),
                      const SizedBox(height: 24),
                      _AnalysisSection(
                        title: '판단 결과',
                        icon: Icons.gavel_rounded,
                        content: report.detailedFeedback,
                      ),
                      const SizedBox(height: 16),
                      _EvidenceAnalysisSection(
                        analysis: report.evidenceAnalysis,
                      ),
                      if (report.recommendations.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _TipSection(recommendations: report.recommendations),
                      ],
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: GameProgress.instance,
                        builder: (context, _) => _XpBar(
                          xp: GameProgress.instance.totalXp,
                          levelLabel: GameProgress.instance.levelLabel,
                          level: GameProgress.instance.level,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _backToList,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('목록으로'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _backToList,
                              child: const Text('다음 훈련 →'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.report});

  final ScenarioReport report;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stars = report.starRating;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: stars >= 3
              ? AppColors.alarm.withValues(alpha: 0.5)
              : AppColors.border,
        ),
        gradient: stars >= 3
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.alarm.withValues(alpha: 0.08),
                  AppColors.surface,
                ],
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            stars >= 3
                ? '완벽한 대응!'
                : stars >= 2
                ? '잘 하셨습니다'
                : '아직 성장 중...',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '정확도 ${report.accuracyScore}점',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.alarm,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.alarm.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '+${report.xpEarned} XP 획득!',
              style: textTheme.titleMedium?.copyWith(color: AppColors.alarm),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.alarm, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(color: AppColors.alarm),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceAnalysisSection extends StatelessWidget {
  const _EvidenceAnalysisSection({required this.analysis});

  final EvidenceAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_rounded,
                color: AppColors.alarm,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '증거 판정',
                style: textTheme.labelLarge?.copyWith(color: AppColors.alarm),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '전체 ${analysis.totalCount}개 중 ${analysis.submittedCount}개를 제출했습니다.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
          if (analysis.missedEvidence.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.border),
            const SizedBox(height: 10),
            Text(
              '놓친 증거',
              style: textTheme.labelMedium?.copyWith(color: AppColors.alarm),
            ),
            const SizedBox(height: 8),
            for (final item in analysis.missedEvidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ${item.value}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TipSection extends StatelessWidget {
  const _TipSection({required this.recommendations});

  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.safe.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.safe.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppColors.safe, size: 20),
              const SizedBox(width: 8),
              Text(
                '추천',
                style: textTheme.labelLarge?.copyWith(color: AppColors.safe),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendations.map((r) => '• $r').join('\n'),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.safe,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _XpBar extends StatefulWidget {
  const _XpBar({
    required this.xp,
    required this.levelLabel,
    required this.level,
  });

  final int xp;
  final String levelLabel;
  final int level;

  @override
  State<_XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<_XpBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final progressWithinLevel = (widget.xp % 1000) / 1000;
    _anim = Tween<double>(
      begin: 0,
      end: progressWithinLevel,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lv.${widget.level} ${widget.levelLabel}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '누적 ${widget.xp} XP',
              style: textTheme.labelMedium?.copyWith(color: AppColors.alarm),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: _anim.value,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.alarm),
            ),
          ),
        ),
      ],
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: List.generate(total, (i) {
          final filled = i < current;
          final active = i == current - 1;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.alarm
                    : filled
                    ? AppColors.safe
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
