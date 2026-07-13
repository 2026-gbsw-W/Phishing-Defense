import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/scenario.dart';
import '../../services/evidence_collector.dart';
import '../../theme/app_colors.dart';
import '../stage2_chat/chat_screen.dart';

class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key, required this.scenario});

  final Scenario scenario;

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  final _evidenceCollector = EvidenceCollector();

  bool _messageVisible = false;
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _messageVisible = true);
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    if (mounted) setState(() => _ttsReady = true);
  }

  Future<void> _readAloud() async {
    await _tts.speak(widget.scenario.smsContent);
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _proceedToChat() {
    _tts.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          scenario: widget.scenario,
          evidenceCollector: _evidenceCollector,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 1 · 메시지 수신'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StageProgressBar(current: 1, total: 6),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📩 새로운 문자가 도착했습니다',
                style: textTheme.labelLarge?.copyWith(color: AppColors.amber),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _messageVisible ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: _SmsCard(
                  sender: widget.scenario.senderName,
                  content: widget.scenario.smsContent,
                  onReadAloud: _ttsReady ? _readAloud : null,
                ),
              ),
              const Spacer(),
              _SuspicionBanner(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('뒤로'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: ElevatedButton(
                        onPressed: _proceedToChat,
                        child: const Text('훈련 시작하기 →'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmsCard extends StatelessWidget {
  const _SmsCard({
    required this.sender,
    required this.content,
    required this.onReadAloud,
  });

  final String sender;
  final String content;
  final VoidCallback? onReadAloud;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.alarm.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.alarm.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    color: AppColors.alarm,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sender,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.alarm,
                        ),
                      ),
                      Text(
                        '방금 전',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onReadAloud != null)
                  IconButton(
                    onPressed: onReadAloud,
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: '소리로 읽기',
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuspicionBanner extends StatelessWidget {
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
            Icons.lightbulb_outline_rounded,
            color: AppColors.amber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '이 메시지가 진짜인지 AI와 대화해보며 확인해보세요!',
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
