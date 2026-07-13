import 'package:flutter/material.dart';

import '../../models/scenario.dart';
import '../../services/evidence_collector.dart';
import '../../theme/app_colors.dart';
import '../stage5_report/report_screen.dart';

class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({
    super.key,
    required this.scenario,
    required this.judgedCorrectly,
    required this.judgmentTurn,
    required this.wrongAttempts,
    required this.evidenceCollector,
  });

  final Scenario scenario;
  final bool judgedCorrectly;
  final int judgmentTurn;
  final int wrongAttempts;
  final EvidenceCollector evidenceCollector;

  void _proceedToReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          scenario: scenario,
          judgedCorrectly: judgedCorrectly,
          judgmentTurn: judgmentTurn,
          wrongAttempts: wrongAttempts,
          evidenceCollector: evidenceCollector,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 4 · 증거 정리'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StageProgressBar(current: 4, total: 6),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📎 내가 모은 증거',
                style: textTheme.labelLarge?.copyWith(color: AppColors.amber),
              ),
              const SizedBox(height: 4),
              Text(
                '대화 중 직접 저장한 항목입니다.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: evidenceCollector,
                  builder: (context, _) {
                    final saved = evidenceCollector.saved;
                    if (saved.isEmpty) {
                      return const _EmptyState();
                    }
                    return ListView.separated(
                      itemCount: saved.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final item = saved[i];
                        return _SavedEvidenceTile(
                          sourceText: item.sourceText,
                          onRemove: () =>
                              evidenceCollector.remove(item.sourceText),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _PendingJudgmentNotice(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _proceedToReport(context),
                  child: const Text('다음: Stage 5 신고 →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bookmark_border_rounded,
            color: AppColors.textSecondary,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            '아직 저장한 증거가 없어요',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '대화 화면으로 돌아가 의심스러운 대사를\n길게 눌러 저장할 수 있습니다.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedEvidenceTile extends StatelessWidget {
  const _SavedEvidenceTile({required this.sourceText, required this.onRemove});

  final String sourceText;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.safe.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box_rounded, color: AppColors.safe),
          const SizedBox(width: 12),
          Expanded(child: Text('"$sourceText"', style: textTheme.bodyMedium)),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
            tooltip: '증거함에서 제거',
          ),
        ],
      ),
    );
  }
}

class _PendingJudgmentNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.amber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '이 중 실제로 증거가 되는지는 신고 후 리포트에서 AI가 하나씩 판정해 드립니다.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.amber),
            ),
          ),
        ],
      ),
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
