import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../logic/scoring.dart';
import '../../models/scenario.dart';
import '../../services/game_progress.dart';
import '../../theme/app_colors.dart';
import '../scenario_selection/scenario_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.scenario,
    required this.judgedCorrectly,
    required this.judgmentTurn,
    required this.evidenceCollectedPercentage,
    required this.reportHandledCount,
  });

  final Scenario scenario;
  final bool judgedCorrectly;
  final int judgmentTurn;
  final int evidenceCollectedPercentage;
  final int reportHandledCount;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  late final ScoreBreakdown _score;

  @override
  void initState() {
    super.initState();
    _score = calculateScore(
      judgedCorrectly: widget.judgedCorrectly,
      judgmentTurn: widget.judgmentTurn,
      evidenceCollectedPercentage: widget.evidenceCollectedPercentage,
      reportHandledCount: widget.reportHandledCount,
    );

    GameProgress.instance.recordCompletion(
      scenarioId: widget.scenario.id,
      xpEarned: _score.totalXp,
    );

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _scaleCtrl.forward();
        if (_score.starRating >= 2) _confetti.play();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleCtrl.dispose();
    super.dispose();
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
      body: Stack(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: _ScoreBadge(score: _score),
                  ),
                  const SizedBox(height: 24),
                  _AnalysisSection(
                    title: '판단 결과 (${_score.accuracyScore}/50점)',
                    icon: Icons.gavel_rounded,
                    color: widget.judgedCorrectly ? AppColors.safe : AppColors.alarm,
                    content: widget.judgedCorrectly
                        ? '${widget.judgmentTurn}번째 대화에서 피싱을 정확히 감지하셨습니다!'
                            '${widget.judgmentTurn <= 2 ? ' 의심 단서를 빠르게 포착하는 능력이 뛰어납니다.' : widget.judgmentTurn <= 4 ? ' 조금 더 빠르게 의심할 수 있다면 더 좋습니다.' : ' 다음엔 조금 더 빠르게 의심해보세요.'}'
                        : '이번엔 피싱 여부를 잘못 판단하셨습니다. 대화 속 단서를 다시 확인해보세요.',
                  ),
                  const SizedBox(height: 16),
                  _AnalysisSection(
                    title: '증거 수집 (${_score.evidenceScore}/20점)',
                    icon: Icons.search_rounded,
                    color: AppColors.amber,
                    content:
                        '수집률 ${widget.evidenceCollectedPercentage}%를 달성했습니다. 놓친 증거는 아래 목록에서 확인하세요.',
                  ),
                  const SizedBox(height: 16),
                  _AnalysisSection(
                    title: '신고 대처 (${_score.reportScore}/20점)',
                    icon: Icons.local_police_rounded,
                    color: AppColors.safe,
                    content: widget.reportHandledCount >= 2
                        ? '경찰·은행 신고 모두 명확하게 대응하셨습니다.'
                        : widget.reportHandledCount == 1
                            ? '한쪽 신고만 완료했습니다. 다음엔 양쪽 모두 대응해보세요.'
                            : '신고 대응이 부족했습니다.',
                  ),
                  const SizedBox(height: 16),
                  _EvidenceSection(hints: widget.scenario.phishingHints),
                  const SizedBox(height: 16),
                  _TipSection(),
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
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScenarioSelectionScreen()),
                              (_) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('목록으로'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScenarioSelectionScreen()),
                              (_) => false,
                            );
                          },
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
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final ScoreBreakdown score;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stars = score.starRating;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: stars >= 3 ? AppColors.amber.withValues(alpha: 0.5) : AppColors.border,
        ),
        gradient: stars >= 3
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.amber.withValues(alpha: 0.08),
                  AppColors.surface,
                ],
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            stars >= 3 ? '완벽한 대응! 🎉' : stars >= 2 ? '잘 하셨습니다 👍' : '아직 성장 중... 💪',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '총점 ${score.totalScore}/100점',
            style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.amber,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '+${score.totalXp} XP 획득!',
              style: textTheme.titleMedium?.copyWith(color: AppColors.amber),
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
    required this.color,
    required this.content,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: textTheme.labelLarge?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.hints});

  final List<String> hints;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.alarm, size: 20),
              const SizedBox(width: 8),
              Text('이번 시나리오의 전체 단서',
                  style: textTheme.labelLarge?.copyWith(color: AppColors.alarm)),
            ],
          ),
          const SizedBox(height: 14),
          ...hints.map(
            (hint) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.alarm,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(hint,
                        style:
                            textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.safe.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.safe.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppColors.safe, size: 20),
              const SizedBox(width: 8),
              Text('실전 대응 팁',
                  style: textTheme.labelLarge?.copyWith(color: AppColors.safe)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 공공기관은 전화·문자로 개인정보를 요구하지 않습니다.\n'
            '• 의심되면 해당 기관 공식 번호(114)로 직접 확인하세요.\n'
            '• 링크는 절대 클릭하지 말고 직접 검색해서 접속하세요.',
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
  const _XpBar({required this.xp, required this.levelLabel, required this.level});

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
        vsync: this, duration: const Duration(milliseconds: 1200));
    final progressWithinLevel = (widget.xp % 1000) / 1000;
    _anim = Tween<double>(begin: 0, end: progressWithinLevel)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
            Text('Lv.${widget.level} ${widget.levelLabel}',
                style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
            Text('누적 ${widget.xp} XP',
                style: textTheme.labelMedium?.copyWith(color: AppColors.amber)),
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
              valueColor: const AlwaysStoppedAnimation(AppColors.amber),
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
                    ? AppColors.amber
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
