import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../logic/scoring.dart';
import '../../models/scenario.dart';
import '../../services/evidence_collector.dart';
import '../../services/game_progress.dart';
import '../../theme/app_colors.dart';
import '../scenario_selection/scenario_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.scenario,
    required this.judgedCorrectly,
    required this.judgmentTurn,
    required this.wrongAttempts,
    required this.evidenceCollector,
    required this.reportHandledCount,
  });

  final Scenario scenario;
  final bool judgedCorrectly;
  final int judgmentTurn;
  final int wrongAttempts;
  final EvidenceCollector evidenceCollector;
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
  late final List<SavedEvidence> _validSubmitted;
  late final List<SavedEvidence> _invalidSubmitted;
  late final List<EvidenceItem> _missedEvidence;

  @override
  void initState() {
    super.initState();

    final submitted = widget.evidenceCollector.submittedEvidence;
    _validSubmitted = submitted.where((e) => e.isValid).toList();
    _invalidSubmitted = submitted.where((e) => !e.isValid).toList();

    final matchedLabels = _validSubmitted.map((e) => e.matchedLabel).toSet();
    _missedEvidence = widget.scenario.evidence
        .where((item) => !matchedLabels.contains(item.label))
        .toList();

    _score = calculateScore(
      judgedCorrectly: widget.judgedCorrectly,
      judgmentTurn: widget.judgmentTurn,
      wrongAttempts: widget.wrongAttempts,
      evidenceTotalCatalog: widget.scenario.evidence.length,
      evidenceValidSubmittedCount: _validSubmitted.length,
      evidenceInvalidSubmittedCount: _invalidSubmitted.length,
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
                    color: widget.judgedCorrectly
                        ? AppColors.safe
                        : AppColors.alarm,
                    content: widget.judgedCorrectly
                        ? widget.wrongAttempts > 0
                              ? '한 번 오판했지만 다시 생각해서 정답을 맞히셨습니다. 처음부터 신중하게 판단하는 연습을 더 해보세요.'
                              : '${widget.judgmentTurn}번째 대화에서 피싱을 정확히 감지하셨습니다!'
                                    '${widget.judgmentTurn <= 2
                                        ? ' 의심 단서를 빠르게 포착하는 능력이 뛰어납니다.'
                                        : widget.judgmentTurn <= 4
                                        ? ' 조금 더 빠르게 의심할 수 있다면 더 좋습니다.'
                                        : ' 다음엔 조금 더 빠르게 의심해보세요.'}'
                        : '${widget.wrongAttempts}번의 기회에도 피싱 여부를 잘못 판단하셨습니다. 대화 속 단서를 다시 확인해보세요.',
                  ),
                  const SizedBox(height: 16),
                  _AnalysisSection(
                    title: '증거 판정 (${_score.evidenceScore}/20점)',
                    icon: Icons.search_rounded,
                    color: AppColors.alarm,
                    content:
                        _validSubmitted.isEmpty && _invalidSubmitted.isEmpty
                        ? '제출한 증거가 없습니다. 다음엔 대화 중 의심스러운 대사를 저장해 제출해보세요.'
                        : '제출 ${_validSubmitted.length + _invalidSubmitted.length}개 중 ${_validSubmitted.length}개가 유효한 증거로 인정됐습니다.',
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
                  _EvidenceJudgmentSection(
                    validSubmitted: _validSubmitted,
                    invalidSubmitted: _invalidSubmitted,
                    missed: _missedEvidence,
                  ),
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
                                builder: (_) => const ScenarioSelectionScreen(),
                              ),
                              (_) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                builder: (_) => const ScenarioSelectionScreen(),
                              ),
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
            '총점 ${score.totalScore}/100점',
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
              '+${score.totalXp} XP 획득!',
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
        borderRadius: BorderRadius.circular(4),
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

class _EvidenceJudgmentSection extends StatelessWidget {
  const _EvidenceJudgmentSection({
    required this.validSubmitted,
    required this.invalidSubmitted,
    required this.missed,
  });

  final List<SavedEvidence> validSubmitted;
  final List<SavedEvidence> invalidSubmitted;
  final List<EvidenceItem> missed;

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
                '제출한 증거 판정',
                style: textTheme.labelLarge?.copyWith(color: AppColors.alarm),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final e in validSubmitted)
            _JudgmentRow(
              valid: true,
              text: e.sourceText,
              reason: '"${e.matchedLabel}" 항목의 유효한 증거로 인정됩니다.',
            ),
          for (final e in invalidSubmitted)
            _JudgmentRow(
              valid: false,
              text: e.sourceText,
              reason: '정황일 뿐 단독 증거로 보기 어렵습니다.',
            ),
          if (validSubmitted.isEmpty && invalidSubmitted.isEmpty)
            Text(
              '제출한 증거가 없어 판정할 항목이 없습니다.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (missed.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.border),
            const SizedBox(height: 10),
            Text(
              '놓친 증거',
              style: textTheme.labelMedium?.copyWith(color: AppColors.alarm),
            ),
            const SizedBox(height: 8),
            for (final item in missed)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ${item.label}',
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

class _JudgmentRow extends StatelessWidget {
  const _JudgmentRow({
    required this.valid,
    required this.text,
    required this.reason,
  });

  final bool valid;
  final String text;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = valid ? AppColors.safe : AppColors.alarm;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            valid ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$text"',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
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
                '실전 대응 팁',
                style: textTheme.labelLarge?.copyWith(color: AppColors.safe),
              ),
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
