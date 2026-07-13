import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../stage5_report/report_screen.dart';

class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({
    super.key,
    required this.recordId,
    this.manualEvidence = const [],
  });

  final int recordId;
  final List<String> manualEvidence;

  void _proceed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(recordId: recordId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasEvidence = manualEvidence.isNotEmpty;

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
              // ── 헤더 ──────────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.bookmark_rounded, size: 16, color: AppColors.alarm),
                  const SizedBox(width: 6),
                  Text(
                    '직접 저장한 증거',
                    style: textTheme.labelLarge?.copyWith(color: AppColors.alarm),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alarm.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${manualEvidence.length}개',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.alarm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '채팅에서 꾹 눌러 저장한 증거입니다. AI가 평가 후 리포트에 반영합니다.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // ── 증거 목록 ──────────────────────────────────────────────────
              Expanded(
                child: hasEvidence
                    ? ListView.separated(
                        itemCount: manualEvidence.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _EvidenceTile(
                          index: i + 1,
                          text: manualEvidence[i],
                        ),
                      )
                    : _EmptyState(textTheme: textTheme),
              ),

              const SizedBox(height: 16),

              // ── AI 평가 안내 ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasEvidence
                            ? '저장된 증거 ${manualEvidence.length}개가 신고 시 AI 평가에 제출됩니다.'
                            : '저장한 증거가 없어도 신고를 진행할 수 있습니다.',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.amber),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 다음 단계 버튼 ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _proceed(context),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('다음: Stage 5 신고 →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 증거 타일 ────────────────────────────────────────────────────────────────

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alarm.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.alarm.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.alarm,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"$text"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.bookmark_rounded, color: AppColors.alarm, size: 16),
        ],
      ),
    );
  }
}

// ─── 빈 상태 ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.textSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '저장한 증거가 없어요',
            style: textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '채팅에서 AI 발언을 꾹 눌러\n증거로 저장할 수 있어요',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── 스테이지 프로그레스 바 ───────────────────────────────────────────────────

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
