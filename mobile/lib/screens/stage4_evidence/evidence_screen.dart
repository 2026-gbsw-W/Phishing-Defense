import 'package:flutter/material.dart';

import '../../models/game/evidence_item.dart';
import '../../services/game_api.dart';
import '../../theme/app_colors.dart';
import '../stage5_report/report_screen.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({
    super.key,
    required this.recordId,
    this.manualEvidence = const [],
  });

  final int recordId;
  final List<String> manualEvidence;

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  late Future<List<EvidenceItem>> _future;
  final _selectedIds = <int>{};
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _future = GameApi.getEvidence(widget.recordId);
  }

  void _retry() {
    setState(() => _future = GameApi.getEvidence(widget.recordId));
  }

  Future<void> _proceedToReport() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await GameApi.confirmEvidence(widget.recordId, _selectedIds.toList());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(recordId: widget.recordId),
        ),
      );
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_rounded,
                    size: 16,
                    color: AppColors.alarm,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '발견된 증거',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.alarm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '신고에 제출할 증거를 선택하세요.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<EvidenceItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.alarm,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                        message: snapshot.error.toString(),
                        onRetry: _retry,
                      );
                    }

                    final items = snapshot.data!;
                    final hasManual = widget.manualEvidence.isNotEmpty;
                    if (items.isEmpty && !hasManual) {
                      return const _EmptyState();
                    }
                    return ListView(
                      children: [
                        if (hasManual) ...[
                          _SectionLabel(
                            icon: Icons.bookmark_rounded,
                            label: '직접 저장한 증거',
                            color: AppColors.alarm,
                          ),
                          const SizedBox(height: 8),
                          ...widget.manualEvidence.map(
                            (text) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ManualEvidenceTile(text: text),
                            ),
                          ),
                          if (items.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _SectionLabel(
                              icon: Icons.auto_awesome_rounded,
                              label: 'AI가 발견한 증거',
                              color: AppColors.safe,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _EvidenceTile(
                              item: item,
                              selected: _selectedIds.contains(item.evidenceId),
                              onToggle: (checked) => setState(() {
                                if (checked) {
                                  _selectedIds.add(item.evidenceId);
                                } else {
                                  _selectedIds.remove(item.evidenceId);
                                }
                              }),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_errorText != null) ...[
                Text(
                  _errorText!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.alarm),
                ),
                const SizedBox(height: 8),
              ],
              _PendingJudgmentNotice(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _proceedToReport,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onAlarm,
                          ),
                        )
                      : const Text('다음: Stage 5 신고 →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ManualEvidenceTile extends StatelessWidget {
  const _ManualEvidenceTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alarm.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.alarm.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_rounded, color: AppColors.alarm, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text('"$text"', style: textTheme.bodyMedium),
          ),
        ],
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
            '발견된 증거가 없어요',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
            message,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.item,
    required this.selected,
    required this.onToggle,
  });

  final EvidenceItem item;
  final bool selected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => onToggle(!selected),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppColors.safe.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box_rounded : Icons.check_box_outline_blank,
              color: selected ? AppColors.safe : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('"${item.value}"', style: textTheme.bodyMedium),
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(4),
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
              '선택한 증거는 신고 후 리포트에서 채점에 반영됩니다.',
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
