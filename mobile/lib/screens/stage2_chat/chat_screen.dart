import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../logic/ai_response_engine.dart';
import '../../models/scenario.dart';
import '../../services/evidence_collector.dart';
import '../../theme/app_colors.dart';
import '../stage3_judge/judge_screen.dart';

class _ChatMsg {
  _ChatMsg({
    required this.text,
    required this.isUser,
    this.isNew = false,
    this.evidenceLabel,
  });
  final String text;
  final bool isUser;
  final bool isNew;
  final String? evidenceLabel;

  bool get isSaveable => !isUser;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.scenario,
    required this.evidenceCollector,
  });

  final Scenario scenario;
  final EvidenceCollector evidenceCollector;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final _msgs = <_ChatMsg>[];
  late final FlutterTts _tts;

  bool _isAiTyping = false;
  int _turnIndex = 0;
  int _scriptIndex = 0;

  final AiResponseEngine _engine = const ScriptedAiResponseEngine();

  bool get _hasMoreChoices => _turnIndex < widget.scenario.chatChoices.length;
  bool get _canProceed => _turnIndex >= 2;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) => _addAiOpener());
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.45);
  }

  void _addAiOpener() {
    final opener = widget.scenario.aiOpener;
    setState(() {
      _msgs.add(
        _ChatMsg(
          text: opener.text,
          isUser: false,
          evidenceLabel: opener.evidenceLabel,
        ),
      );
    });
    _tts.speak(opener.text);
    _scrollToBottom();
  }

  void _saveAsEvidence(_ChatMsg msg) {
    widget.evidenceCollector.save(
      SavedEvidence(sourceText: msg.text, matchedLabel: msg.evidenceLabel),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📎 증거로 저장했습니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _choose(ChatChoice choice) async {
    if (_isAiTyping || !_hasMoreChoices) return;

    setState(() {
      _msgs.add(_ChatMsg(text: choice.label, isUser: true));
      _isAiTyping = true;
    });
    _scrollToBottom();

    final delay = Future.delayed(const Duration(milliseconds: 1200));
    final result = await _engine.respond(
      scenario: widget.scenario,
      branch: choice.branch,
      scriptIndex: _scriptIndex,
      turnIndex: _turnIndex,
    );
    await delay;
    if (result.consumedScript) _scriptIndex++;

    if (mounted) {
      setState(() {
        _isAiTyping = false;
        _msgs.add(
          _ChatMsg(
            text: result.line.text,
            isUser: false,
            isNew: true,
            evidenceLabel: result.line.evidenceLabel,
          ),
        );
        _turnIndex++;
      });
      _tts.speak(result.line.text);
      _scrollToBottom();
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

  void _proceedToJudge() {
    _tts.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JudgeScreen(
          scenario: widget.scenario,
          judgmentTurn: _turnIndex,
          evidenceCollector: widget.evidenceCollector,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final choices = _hasMoreChoices
        ? widget.scenario.chatChoices[_turnIndex]
        : const <ChatChoice>[];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.scenario.senderName,
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
          if (_canProceed)
            TextButton(
              onPressed: _proceedToJudge,
              child: Text(
                '판단하기 →',
                style: TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.evidenceCollector,
        builder: (context, _) => Column(
          children: [
            _EvidenceTray(count: widget.evidenceCollector.saved.length),
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
                    isSaved: widget.evidenceCollector.isSaved(msg.text),
                    onLongPress: msg.isSaveable
                        ? () => _saveAsEvidence(msg)
                        : null,
                  );
                },
              ),
            ),
            if (_canProceed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: GestureDetector(
                  onTap: _proceedToJudge,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.amber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '피싱 여부를 판단할 준비가 됐다면 →',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.amber),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_hasMoreChoices)
              _ChoiceBar(
                choices: choices,
                enabled: !_isAiTyping,
                onChoose: _choose,
              ),
          ],
        ),
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
          const Icon(Icons.bookmark_rounded, color: AppColors.amber, size: 16),
          const SizedBox(width: 6),
          Text(
            '내 증거함 ($count개 저장됨)',
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
  const _Bubble({required this.msg, required this.isSaved, this.onLongPress});
  final _ChatMsg msg;
  final bool isSaved;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUser = msg.isUser;

    return Padding(
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
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.amber : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: Border.all(
                    color: isSaved
                        ? AppColors.amber
                        : isUser
                        ? Colors.transparent
                        : AppColors.border,
                    width: isSaved ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    !isUser && msg.isNew
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
                                  ? AppColors.background
                                  : AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                    if (isSaved) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_rounded,
                            size: 12,
                            color: isUser
                                ? AppColors.background
                                : AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '증거로 저장됨',
                            style: textTheme.labelSmall?.copyWith(
                              color: isUser
                                  ? AppColors.background
                                  : AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
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

class _ChoiceBar extends StatelessWidget {
  const _ChoiceBar({
    required this.choices,
    required this.enabled,
    required this.onChoose,
  });

  final List<ChatChoice> choices;
  final bool enabled;
  final void Function(ChatChoice choice) onChoose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final choice in choices) ...[
              _ChoiceButton(
                label: choice.label,
                enabled: enabled,
                onTap: () => onChoose(choice),
              ),
              if (choice != choices.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
