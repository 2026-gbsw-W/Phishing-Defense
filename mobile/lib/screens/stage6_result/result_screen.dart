import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../models/scenario.dart';
import '../../theme/app_colors.dart';
import '../scenario_selection/scenario_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.scenario,
    required this.judgedCorrectly,
  });

  final Scenario scenario;
  final bool judgedCorrectly;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  late final int _stars;
  late final int _xp;

  @override
  void initState() {
    super.initState();
    _stars = widget.judgedCorrectly ? 3 : 1;
    _xp = widget.judgedCorrectly ? 280 : 100;

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _scaleCtrl.forward();
        if (widget.judgedCorrectly) _confetti.play();
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
                    child: _ScoreBadge(stars: _stars, xp: _xp),
                  ),
                  const SizedBox(height: 24),
                  _AnalysisSection(
                    title: '판단 결과',
                    icon: Icons.gavel_rounded,
                    color: widget.judgedCorrectly ? AppColors.safe : AppColors.alarm,
                    content: widget.judgedCorrectly
                        ? '피싱을 정확히 감지하셨습니다! 의심 단서를 빠르게 포착하는 능력이 뛰어납니다.'
                        : '이번엔 피싱을 놓치셨습니다. 아래 단서들을 확인하고 다시 도전해보세요.',
                  ),
                  const SizedBox(height: 16),
                  _EvidenceSection(hints: widget.scenario.phishingHints),
                  const SizedBox(height: 16),
                  _TipSection(),
                  const SizedBox(height: 32),
                  _XpBar(xp: _xp, maxXp: 330),
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
  const _ScoreBadge({required this.stars, required this.xp});

  final int stars;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              '+$xp XP 획득!',
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
              Text('놓치면 안 될 단서들',
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
  const _XpBar({required this.xp, required this.maxXp});

  final int xp;
  final int maxXp;

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
    _anim = Tween<double>(begin: 0, end: widget.xp / widget.maxXp)
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
            Text('Lv.1 시민', style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
            Text('${widget.xp} / ${widget.maxXp} XP',
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
