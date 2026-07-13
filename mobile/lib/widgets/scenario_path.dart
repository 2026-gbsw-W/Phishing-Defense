import 'package:flutter/material.dart';

import '../models/game/chapter.dart';
import '../models/game/stage.dart';
import '../theme/app_colors.dart';

enum _NodeState { completed, current, locked }

/// 듀오링고 챕터 화면처럼 챕터 배너 아래에 굽이치는 경로를 따라 스테이지
/// 노드를 배치한다. 이전 스테이지를 완료해야 다음 스테이지가 열린다.
class ChapterPathSection extends StatelessWidget {
  const ChapterPathSection({
    super.key,
    required this.chapter,
    required this.stages,
    required this.isUnlocked,
    required this.onStageTap,
    required this.onLockedTap,
  });

  final Chapter chapter;
  final List<Stage> stages;

  /// 전체(챕터 통합) 순서 기준으로 이 스테이지가 열려 있는지 여부.
  final bool Function(Stage stage) isUnlocked;
  final ValueChanged<Stage> onStageTap;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completedCount = stages.where((s) => s.completed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.title, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      chapter.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.alarm.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completedCount / ${stages.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.alarm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (stages.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '준비 중입니다.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          _WindingPath(
            stages: stages,
            isUnlocked: isUnlocked,
            onStageTap: onStageTap,
            onLockedTap: onLockedTap,
          ),
      ],
    );
  }
}

const _rowHeight = 108.0;
const _nodeOffsets = [0.5, 0.78, 0.5, 0.22];

class _WindingPath extends StatelessWidget {
  const _WindingPath({
    required this.stages,
    required this.isUnlocked,
    required this.onStageTap,
    required this.onLockedTap,
  });

  final List<Stage> stages;
  final bool Function(Stage stage) isUnlocked;
  final ValueChanged<Stage> onStageTap;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = _rowHeight * stages.length;
        final centers = [
          for (var i = 0; i < stages.length; i++)
            Offset(
              _nodeOffsets[i % _nodeOffsets.length] * width,
              _rowHeight * i + _rowHeight / 2,
            ),
        ];

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _PathPainter(centers: centers),
              ),
              for (var i = 0; i < stages.length; i++)
                _buildNode(context, i, centers[i]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNode(BuildContext context, int index, Offset center) {
    final stage = stages[index];
    final unlocked = isUnlocked(stage);
    final isNextUp = unlocked && !stage.completed;
    final state = stage.completed
        ? _NodeState.completed
        : unlocked
        ? _NodeState.current
        : _NodeState.locked;

    const nodeSize = 64.0;
    const bigNodeSize = 76.0;
    final size = state == _NodeState.current ? bigNodeSize : nodeSize;

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: Column(
        children: [
          if (isNextUp)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.alarm,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '시작',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onAlarm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          _ScenarioNode(
            state: state,
            size: size,
            onTap: () => unlocked ? onStageTap(stage) : onLockedTap(),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 96,
            child: Text(
              stage.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: state == _NodeState.locked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioNode extends StatelessWidget {
  const _ScenarioNode({
    required this.state,
    required this.size,
    required this.onTap,
  });

  final _NodeState state;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    final IconData icon;
    final Color iconColor;

    switch (state) {
      case _NodeState.completed:
        fill = AppColors.safe.withValues(alpha: 0.15);
        border = AppColors.safe;
        icon = Icons.check_rounded;
        iconColor = AppColors.safe;
        break;
      case _NodeState.current:
        fill = AppColors.alarm;
        border = AppColors.alarm;
        icon = Icons.play_arrow_rounded;
        iconColor = AppColors.onAlarm;
        break;
      case _NodeState.locked:
        fill = AppColors.surface;
        border = AppColors.border;
        icon = Icons.lock_rounded;
        iconColor = AppColors.textSecondary;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 2),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.42),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({required this.centers});

  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < centers.length - 1; i++) {
      _drawDashedLine(canvas, centers[i], centers[i + 1], paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 10.0;
    const gapLength = 8.0;
    final total = (end - start).distance;
    final direction = (end - start) / total;

    var drawn = 0.0;
    while (drawn < total) {
      final segmentEnd = (drawn + dashLength).clamp(0.0, total);
      canvas.drawLine(
        start + direction * drawn,
        start + direction * segmentEnd,
        paint,
      );
      drawn += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      oldDelegate.centers != centers;
}
