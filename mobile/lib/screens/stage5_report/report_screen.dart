import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../stage6_result/result_screen.dart';

/// 경찰/은행 신고 연출 화면. 백엔드에 대응하는 신고 API가 없어 순수
/// 로컬 연출(캔드 응답)로만 동작하며, recordId만 다음 화면으로 전달한다.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.recordId});

  final int recordId;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _policeController = TextEditingController();
  final _bankController = TextEditingController();

  bool _policeSent = false;
  bool _bankSent = false;
  String? _policeReply;
  String? _bankReply;

  void _sendPolice() {
    final text = _policeController.text.trim();
    if (text.isEmpty || _policeSent) return;
    setState(() {
      _policeSent = true;
      _policeReply = '신고가 접수되었습니다. 사건번호가 발급되었으며, 담당 수사관이 배정될 예정입니다.';
    });
  }

  void _sendBank() {
    final text = _bankController.text.trim();
    if (text.isEmpty || _bankSent) return;
    setState(() {
      _bankSent = true;
      _bankReply = '말씀하신 계좌에 지급정지 조치를 접수했습니다. 피해 구제 신청서는 영업일 기준 3일 내 안내드립니다.';
    });
  }

  void _proceedToResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(recordId: widget.recordId),
      ),
    );
  }

  @override
  void dispose() {
    _policeController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bothSent = _policeSent && _bankSent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 5 · 신고 프로세스'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StageProgressBar(current: 5, total: 6),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_phone_rounded,
                    size: 16,
                    color: AppColors.alarm,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '신고 진행 현황',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.alarm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '경찰과 은행에 상황을 설명하고 필요한 조치를 요청하세요.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _ReportCard(
                icon: Icons.local_police_rounded,
                title: '경찰 신고',
                subtitle: '사이버범죄수사팀',
                controller: _policeController,
                sent: _policeSent,
                reply: _policeReply,
                onSend: _sendPolice,
              ),
              const SizedBox(height: 16),
              _ReportCard(
                icon: Icons.account_balance_rounded,
                title: '은행 지급정지 요청',
                subtitle: '고객센터',
                controller: _bankController,
                sent: _bankSent,
                reply: _bankReply,
                onSend: _sendBank,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: bothSent ? _proceedToResult : null,
                  child: Text(bothSent ? '결과 리포트 보기 →' : '경찰·은행 신고를 모두 완료하세요'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.sent,
    required this.reply,
    required this.onSend,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final bool sent;
  final String? reply;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: sent
              ? AppColors.safe.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.alarm.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: AppColors.alarm, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (sent)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.safe,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (reply != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                reply!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: '상황을 설명해 주세요...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.alarm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.alarm,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.onAlarm,
                      size: 20,
                    ),
                  ),
                ),
              ],
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
