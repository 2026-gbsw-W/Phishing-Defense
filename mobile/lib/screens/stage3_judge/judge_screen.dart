import 'package:flutter/material.dart';

import '../../models/scenario.dart';
import '../../services/evidence_collector.dart';
import '../../theme/app_colors.dart';
import '../stage4_evidence/evidence_screen.dart';

class JudgeScreen extends StatefulWidget {
  const JudgeScreen({
    super.key,
    required this.scenario,
    required this.judgmentTurn,
    required this.evidenceCollector,
  });

  final Scenario scenario;
  final int judgmentTurn;
  final EvidenceCollector evidenceCollector;

  @override
  State<JudgeScreen> createState() => _JudgeScreenState();
}

class _JudgeScreenState extends State<JudgeScreen> {
  bool? _userJudgment;
  bool _revealed = false;
  int _wrongAttempts = 0;

  static const _maxWrongAttempts = 2;

  void _judge(bool isPhishing) {
    if (_revealed) return;

    final correct = isPhishing == widget.scenario.isPhishing;
    setState(() {
      _userJudgment = isPhishing;
      if (correct) {
        _revealed = true;
      } else {
        _wrongAttempts++;
        if (_wrongAttempts >= _maxWrongAttempts) _revealed = true;
      }
    });
  }

  void _proceedToEvidence() {
    final correct = _userJudgment == widget.scenario.isPhishing;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvidenceScreen(
          scenario: widget.scenario,
          judgedCorrectly: correct,
          judgmentTurn: widget.judgmentTurn,
          wrongAttempts: _wrongAttempts,
          evidenceCollector: widget.evidenceCollector,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 3 · 피싱 여부 판단'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StageProgressBar(current: 3, total: 6),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '방금 나눈 대화를 떠올려 보세요.',
                style: textTheme.labelLarge?.copyWith(color: AppColors.amber),
              ),
              const SizedBox(height: 8),
              Text('이 메시지는 피싱인가요?', style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '대화 내용과 단서들을 근거로 판단해 주세요.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _HintList(
                hints: widget.scenario.phishingHints,
                revealed: _revealed,
              ),
              const Spacer(),
              if (!_revealed && _wrongAttempts > 0) ...[
                _RetryBanner(attemptsLeft: _maxWrongAttempts - _wrongAttempts),
                const SizedBox(height: 14),
              ],
              if (!_revealed) ...[
                _JudgeButton(
                  label: '🚨 피싱입니다',
                  sublabel: '이것은 사기 시도입니다',
                  color: AppColors.alarm,
                  onTap: () => _judge(true),
                ),
                const SizedBox(height: 14),
                _JudgeButton(
                  label: '✅ 정상 메시지입니다',
                  sublabel: '진짜 기관에서 보낸 메시지입니다',
                  color: AppColors.safe,
                  onTap: () => _judge(false),
                ),
              ] else ...[
                _ResultReveal(
                  userJudgment: _userJudgment! == widget.scenario.isPhishing,
                  onContinue: _proceedToEvidence,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryBanner extends StatelessWidget {
  const _RetryBanner({required this.attemptsLeft});

  final int attemptsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alarm.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.alarm.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.refresh_rounded, color: AppColors.alarm, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '다시 생각해보세요. 대화 속 단서를 다시 살펴보면 도움이 될 거예요. (남은 기회 $attemptsLeft회)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.alarm),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintList extends StatelessWidget {
  const _HintList({required this.hints, required this.revealed});

  final List<String> hints;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.amber,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                revealed ? '발견된 피싱 단서' : '단서를 찾아보셨나요?',
                style: textTheme.labelMedium?.copyWith(color: AppColors.amber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...hints.map(
            (hint) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: revealed
                          ? AppColors.alarm
                          : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      revealed ? hint : '???',
                      style: textTheme.bodyMedium?.copyWith(
                        color: revealed
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
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

class _JudgeButton extends StatelessWidget {
  const _JudgeButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.titleMedium?.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultReveal extends StatelessWidget {
  const _ResultReveal({required this.userJudgment, required this.onContinue});

  final bool userJudgment;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final correct = userJudgment;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (correct ? AppColors.safe : AppColors.alarm).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (correct ? AppColors.safe : AppColors.alarm).withValues(
                alpha: 0.5,
              ),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                correct ? '🎉 정확합니다!' : '😨 아쉽습니다!',
                style: textTheme.headlineSmall?.copyWith(
                  color: correct ? AppColors.safe : AppColors.alarm,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                correct
                    ? '피싱을 올바르게 감지하셨습니다.\n증거 수집과 신고 방법을 확인해보세요!'
                    : '이 메시지는 피싱이었습니다.\n어떤 단서를 놓쳤는지 확인해보세요.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            child: const Text('증거 수집하러 가기 →'),
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
