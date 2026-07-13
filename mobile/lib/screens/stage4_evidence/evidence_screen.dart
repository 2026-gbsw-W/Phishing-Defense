import 'package:flutter/material.dart';

import '../../models/scenario.dart';
import '../../theme/app_colors.dart';
import '../stage5_report/report_screen.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({
    super.key,
    required this.scenario,
    required this.judgedCorrectly,
    required this.judgmentTurn,
  });

  final Scenario scenario;
  final bool judgedCorrectly;
  final int judgmentTurn;

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    // 발신자 정보는 시스템이 자동으로 추출해 항상 선반영된다.
    _selected = {0};
  }

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  void _proceedToReport() {
    final total = widget.scenario.evidence.length;
    final percentage = ((_selected.length / total) * 100).round();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          scenario: widget.scenario,
          judgedCorrectly: widget.judgedCorrectly,
          judgmentTurn: widget.judgmentTurn,
          evidenceCollectedPercentage: percentage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final evidence = widget.scenario.evidence;
    final percentage = ((_selected.length / evidence.length) * 100).round();

    final missed = [
      for (var i = 0; i < evidence.length; i++)
        if (!_selected.contains(i)) evidence[i],
    ]..sort((a, b) => b.importance.compareTo(a.importance));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 4 · 증거 수집'),
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
                '🔍 증거를 수집하세요',
                style: textTheme.labelLarge?.copyWith(color: AppColors.amber),
              ),
              const SizedBox(height: 4),
              Text(
                '대화에서 발견한 의심스러운 정황을 모두 체크하세요.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _CollectionMeter(percentage: percentage),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: evidence.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final item = evidence[i];
                    final checked = _selected.contains(i);
                    return _EvidenceTile(
                      label: item.label,
                      importance: item.importance,
                      checked: checked,
                      onTap: () => _toggle(i),
                    );
                  },
                ),
              ),
              if (missed.isNotEmpty) ...[
                const SizedBox(height: 8),
                _MissedTip(topMissedLabel: missed.first.label),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToReport,
                  child: const Text('다음: 신고하기 →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionMeter extends StatelessWidget {
  const _CollectionMeter({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('수집률', style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
            Text('$percentage%', style: textTheme.labelMedium?.copyWith(color: AppColors.safe)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 10,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.safe),
          ),
        ),
      ],
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.label,
    required this.importance,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final int importance;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: checked ? AppColors.safe.withValues(alpha: 0.6) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: checked ? AppColors.safe : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: textTheme.bodyMedium),
            ),
            Row(
              children: List.generate(
                importance,
                (_) => const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedTip extends StatelessWidget {
  const _MissedTip({required this.topMissedLabel});

  final String topMissedLabel;

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
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '"$topMissedLabel"은(는) 아직 체크하지 않았어요. 신고 시 중요한 증거가 될 수 있습니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.amber),
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
