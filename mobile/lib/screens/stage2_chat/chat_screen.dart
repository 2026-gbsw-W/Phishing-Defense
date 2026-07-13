import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/game/stage.dart';
import '../../services/game_api.dart';
import '../../theme/app_colors.dart';
import '../stage3_judge/judge_screen.dart';

class _ChatMsg {
  _ChatMsg({required this.text, required this.isUser, this.isNew = false});
  final String text;
  final bool isUser;
  final bool isNew;
  bool savedAsEvidence = false;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.stage,
    required this.recordId,
    required this.openerMessage,
  });

  final Stage stage;
  final int recordId;
  final String openerMessage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _msgs = <_ChatMsg>[];
  late final FlutterTts _tts;

  bool _isAiTyping = false;
  bool _hintLoading = false;
  int _turnCount = 0;
  int _evidenceFoundCount = 0;
  bool _hintAvailable = false;

  bool get _canProceed => _turnCount >= 2;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialAiGreeting();
    });
  }

  Future<void> _fetchInitialAiGreeting() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isAiTyping = true);
    _scrollToBottom();
    try {
      // 사용자 메시지를 UI에 표시하지 않고 AI 첫 응답만 받아옴
      final result = await GameApi.sendChat(
        widget.recordId,
        '여보세요',
      );
      if (!mounted) return;
      setState(() {
        _isAiTyping = false;
        // 초기 AI 인사는 턴 카운트에 포함하지 않음 (사용자 대화 기준)
        _turnCount = 0;
        _hintAvailable = result.hintAvailable;
        _msgs.add(_ChatMsg(text: result.aiResponse, isUser: false, isNew: true));
      });
      _tts.speak(result.aiResponse);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isAiTyping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI 연결 오류: $e')),
        );
      }
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.45);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isAiTyping) return;

    _controller.clear();
    _focusNode.unfocus();

    setState(() {
      _msgs.add(_ChatMsg(text: text, isUser: true));
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final delay = Future.delayed(const Duration(milliseconds: 800));
      final result = await GameApi.sendChat(widget.recordId, text);
      await delay;

      if (!mounted) return;
      setState(() {
        _isAiTyping = false;
        _turnCount = result.turn;
        _hintAvailable = result.hintAvailable;
        _msgs.add(
          _ChatMsg(text: result.aiResponse, isUser: false, isNew: true),
        );
      });
      _tts.speak(result.aiResponse);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAiTyping = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showHint() async {
    if (_hintLoading || !_hintAvailable) return;
    setState(() => _hintLoading = true);
    try {
      final hint = await GameApi.getHint(widget.recordId);
      if (!mounted) return;
      setState(() => _hintAvailable = hint.remainingHints > 0);
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('힌트'),
          content: Text(hint.hintText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _hintLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveEvidence(_ChatMsg msg) async {
    if (msg.isUser || msg.savedAsEvidence) return;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.bookmark_add_rounded, color: AppColors.alarm, size: 20),
                SizedBox(width: 8),
                Text('증거로 저장', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(fontSize: 13, height: 1.5),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetCtx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(sheetCtx, true),
                    icon: const Icon(Icons.bookmark_add_rounded, size: 16),
                    label: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        msg.savedAsEvidence = true;
        _evidenceFoundCount += 1;
      });
      // AI 서버 세션에도 증거 등록 (chat/end 분석 시 evidenceFeedback에 반영됨)
      try { await GameApi.saveEvidence(widget.recordId, msg.text); } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.bookmark_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('증거로 저장됐습니다'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.alarm,
        ),
      );
    }
  }

  void _proceedToJudge() {
    _tts.stop();
    final savedTexts = _msgs
        .where((m) => !m.isUser && m.savedAsEvidence)
        .map((m) => m.text)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JudgeScreen(
          recordId: widget.recordId,
          manualEvidence: savedTexts,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stage.title,
              style: textTheme.titleSmall?.copyWith(color: AppColors.alarm),
            ),
            Text(
              'Stage 2 · AI와 대화',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _StageProgressBar(current: 2, total: 6),
        ),
        actions: [
          if (_hintAvailable)
            TextButton(
              onPressed: _hintLoading ? null : _showHint,
              child: Text(
                '힌트',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (_canProceed)
            TextButton(
              onPressed: _proceedToJudge,
              child: Text(
                '판단하기 →',
                style: TextStyle(
                  color: AppColors.alarm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _EvidenceTray(count: _evidenceFoundCount),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isAiTyping && i == _msgs.length) {
                  return const _TypingIndicator();
                }
                final msg = _msgs[i];
                return _Bubble(
                  msg: msg,
                  onLongPress: msg.isUser ? null : () => _saveEvidence(msg),
                );
              },
            ),
          ),
          if (_canProceed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: _proceedToJudge,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.alarm.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.alarm.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.alarm,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '피싱 여부를 판단할 준비가 됐다면 →',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.alarm),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _InputBar(
            controller: _controller,
            focusNode: _focusNode,
            onSend: _send,
            enabled: !_isAiTyping,
          ),
        ],
      ),
    );
  }
}

class _EvidenceTray extends StatelessWidget {
  const _EvidenceTray({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          const Icon(Icons.bookmark_rounded, color: AppColors.alarm, size: 16),
          const SizedBox(width: 6),
          Text(
            '저장한 증거 ($count개) — 꾹 눌러서 저장',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, this.onLongPress});
  final _ChatMsg msg;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUser = msg.isUser;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.alarm.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.alarm,
                size: 18,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.alarm : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser ? Colors.transparent : AppColors.border,
                ),
              ),
              child: !isUser && msg.isNew
                  ? AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          msg.text,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                          speed: const Duration(milliseconds: 28),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    )
                  : Text(
                      msg.text,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? AppColors.onAlarm
                            : AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
          // 증거 저장된 AI 메시지에 북마크 표시
          if (!isUser && msg.savedAsEvidence)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 2),
              child: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.alarm,
                size: 16,
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.alarm.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.alarm,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.2;
                  final opacity = (sin(
                    (_ctrl.value + delay) * pi,
                  )).clamp(0.3, 1.0);
                  return Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.alarm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.alarm : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: enabled ? AppColors.onAlarm : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
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
