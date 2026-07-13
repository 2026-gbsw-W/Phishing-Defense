import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/game/stage.dart';
import '../../services/game_api.dart';
import '../../theme/app_colors.dart';
import '../stage2_chat/chat_screen.dart';
import '../voice_call/voice_call_screen.dart';

class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key, required this.stage});

  final Stage stage;

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _messageVisible = false;
  bool _ttsReady = false;
  bool _starting = false;
  String? _errorText;

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
    await _tts.speak(widget.stage.initialMessage);
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _proceedToChat() async {
    _tts.stop();
    setState(() {
      _starting = true;
      _errorText = null;
    });

    try {
      final start = await GameApi.startScenario(widget.stage.stageId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            stage: widget.stage,
            recordId: start.recordId,
            openerMessage: start.initialMessage,
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _proceedToVoiceCall() async {
    _tts.stop();
    setState(() {
      _starting = true;
      _errorText = null;
    });

    try {
      final start = await GameApi.startScenario(widget.stage.stageId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            stage: widget.stage,
            recordId: start.recordId,
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _starting = false);
    }
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
              Row(
                children: [
                  const Icon(
                    Icons.mail_outline_rounded,
                    size: 16,
                    color: AppColors.alarm,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '새로운 문자가 도착했습니다',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.alarm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _messageVisible ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: _SmsCard(
                  sender: '발신번호 미확인',
                  content: widget.stage.initialMessage,
                  onReadAloud: _ttsReady ? _readAloud : null,
                ),
              ),
              const Spacer(),
              if (_errorText != null) ...[
                Text(
                  _errorText!,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.alarm),
                ),
                const SizedBox(height: 12),
              ],
              _SuspicionBanner(),
              const SizedBox(height: 16),
              // 훈련 모드 선택
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('뒤로'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _starting ? null : _proceedToChat,
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: _starting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.onAlarm,
                                      ),
                                    )
                                  : const Text('채팅으로 훈련'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _starting ? null : _proceedToVoiceCall,
                            icon: const Icon(Icons.mic_rounded, size: 16),
                            label: const Text('음성 통화로 훈련'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.amber,
                              side: BorderSide(color: AppColors.amber.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.alarm.withValues(alpha: 0.6),
              width: 2,
            ),
            left: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            bottom: const BorderSide(color: AppColors.border),
          ),
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
                      borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(4),
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
