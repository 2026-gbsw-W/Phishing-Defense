import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../models/game/stage.dart';
import '../../theme/app_colors.dart';
import '../stage3_judge/judge_screen.dart';

const String _kAiWsBaseUrl = 'ws://localhost:8000';

// ─── 피싱 유형 → 발신자 정보 매핑 ────────────────────────────────────────────

class _CallerInfo {
  const _CallerInfo({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  static _CallerInfo from(String phishingType) {
    switch (phishingType) {
      case 'prosecutor':
      case 'prosecutor_investigation':
        return const _CallerInfo(
          name: '서울중앙지검',
          subtitle: '수사관 박○○ · 02-530-3114',
          icon: Icons.gavel_rounded,
          accentColor: Color(0xFF5C6BC0),
        );
      case 'bank':
      case 'smishing_bank':
        return const _CallerInfo(
          name: '○○은행 고객센터',
          subtitle: '상담원 이○○ · 1588-9999',
          icon: Icons.account_balance_rounded,
          accentColor: Color(0xFF26A69A),
        );
      case 'family':
        return const _CallerInfo(
          name: '가족',
          subtitle: '긴급 연락 · 번호 변경됨',
          icon: Icons.family_restroom_rounded,
          accentColor: Color(0xFF66BB6A),
        );
      case 'delivery':
      case 'smishing_telecom':
        return const _CallerInfo(
          name: '택배 기사',
          subtitle: '배송 안내 · 010-XXXX-XXXX',
          icon: Icons.local_shipping_rounded,
          accentColor: Color(0xFFFF7043),
        );
      case 'loan':
      case 'smishing_loan':
        return const _CallerInfo(
          name: '대출 상담센터',
          subtitle: '금융 상담 · 무료수신',
          icon: Icons.attach_money_rounded,
          accentColor: Color(0xFFAB47BC),
        );
      case 'child_kidnap':
        return const _CallerInfo(
          name: '알 수 없는 번호',
          subtitle: '긴급 연락 · 번호 미확인',
          icon: Icons.warning_rounded,
          accentColor: AppColors.alarm,
        );
      default:
        return const _CallerInfo(
          name: '알 수 없는 번호',
          subtitle: '번호 미확인',
          icon: Icons.phone_rounded,
          accentColor: AppColors.alarm,
        );
    }
  }
}

// ─── 위험 신호 키워드 감지 ────────────────────────────────────────────────────

const _dangerKeywords = [
  '계좌번호', '비밀번호', '인증번호', 'OTP', '송금', '이체', '공인인증서',
  '주민번호', '개인정보', '즉시', '지금 당장', '긴급', '구속', '영장',
  '대출', '수수료', '보안계좌', '안전계좌',
];

String? _detectDanger(String text) {
  for (final kw in _dangerKeywords) {
    if (text.contains(kw)) return '"$kw" 관련 요구 — 주의하세요!';
  }
  return null;
}

// ─── 통화 상태 ────────────────────────────────────────────────────────────────

enum _CallState { connecting, aiSpeaking, userTurn, recording, processing, ended }

// ─── 대화 메시지 ──────────────────────────────────────────────────────────────

class _Msg {
  _Msg({required this.text, required this.isUser, this.danger});
  final String text;
  final bool isUser;
  final String? danger;
}

// ─── 메인 화면 ────────────────────────────────────────────────────────────────

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({
    super.key,
    required this.stage,
    required this.recordId,
  });

  final Stage stage;
  final int recordId;

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with TickerProviderStateMixin {
  // ── 서버 연결 ──────────────────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  bool _expectingAudio = false;
  String? _sessionId; // ignore: unused_field

  // ── 오디오 ─────────────────────────────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();

  // ── 상태 ───────────────────────────────────────────────────────────────────
  _CallState _state = _CallState.connecting;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _showLog = false;

  // ── 대화 ───────────────────────────────────────────────────────────────────
  final _msgs = <_Msg>[];
  String _currentDanger = '';
  final _logScrollCtrl = ScrollController();

  // ── 타이머 ─────────────────────────────────────────────────────────────────
  int _seconds = 0;
  Timer? _timer;

  // ── 애니메이션 ─────────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _waveCtrl;

  late final _CallerInfo _caller;

  @override
  void initState() {
    super.initState();
    _caller = _CallerInfo.from(widget.stage.phishingType);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.20)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });

    _connect();
  }

  // ── WebSocket ──────────────────────────────────────────────────────────────

  void _connect() {
    final type = widget.stage.phishingType.isNotEmpty
        ? _mapToAiScenario(widget.stage.phishingType)
        : 'prosecutor';

    _channel = WebSocketChannel.connect(
      Uri.parse('$_kAiWsBaseUrl/voice-call/$type'),
    );
    _wsSub = _channel!.stream.listen(
      _onWsData,
      onError: (_) => _endCall(),
      onDone: () { if (_state != _CallState.ended) _endCall(); },
    );
  }

  String _mapToAiScenario(String type) {
    const map = {
      'smishing_bank': 'bank',
      'smishing_telecom': 'delivery',
      'smishing_loan': 'loan',
    };
    return map[type] ?? type;
  }

  void _onWsData(dynamic data) {
    if (data is String) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      _sessionId = json['session_id'] as String?;
      final aiText = json['ai_text'] as String? ?? '';
      final userText = json['user_text'] as String?;
      final danger = _detectDanger(aiText);

      setState(() {
        if (userText != null && userText.isNotEmpty) {
          _msgs.add(_Msg(text: userText, isUser: true));
        }
        if (aiText.isNotEmpty) {
          _msgs.add(_Msg(text: aiText, isUser: false, danger: danger));
        }
        _currentDanger = danger ?? '';
        _state = _CallState.aiSpeaking;
        _expectingAudio = true;
      });
      _scrollLog();
    } else if (data is List<int> && _expectingAudio) {
      _expectingAudio = false;
      _playBytes(data);
    }
  }

  Future<void> _playBytes(List<int> bytes) async {
    if (_isMuted) {
      if (mounted) setState(() => _state = _CallState.userTurn);
      return;
    }
    final file = File(
      '${Directory.systemTemp.path}/ai_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    await file.writeAsBytes(bytes);
    await _player.stop();
    await _player.play(DeviceFileSource(file.path));
    _player.onPlayerComplete.first.then((_) {
      if (mounted && _state == _CallState.aiSpeaking) {
        setState(() => _state = _CallState.userTurn);
      }
    });
  }

  // ── 마이크 ─────────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (_isMuted || _state != _CallState.userTurn) return;
    final ok = await _recorder.hasPermission();
    if (!ok) return;
    setState(() => _state = _CallState.recording);
    final path =
        '${Directory.systemTemp.path}/user_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<void> _stopRecording() async {
    if (_state != _CallState.recording) return;
    setState(() => _state = _CallState.processing);
    final path = await _recorder.stop();
    if (path == null) { setState(() => _state = _CallState.userTurn); return; }
    final bytes = await File(path).readAsBytes();
    await File(path).delete();
    _channel?.sink.add(bytes);
    _expectingAudio = false;
  }

  // ── 통화 종료 ──────────────────────────────────────────────────────────────

  void _endCall() {
    if (_state == _CallState.ended) return;
    setState(() => _state = _CallState.ended);
    _channel?.sink.close();
    _timer?.cancel();
    _player.stop();
    _recorder.stop();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => JudgeScreen(recordId: widget.recordId),
        ),
      );
    }
  }

  void _confirmEndCall() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('통화 종료'),
        content: const Text('통화를 종료하고 피싱 판단 화면으로 이동합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('계속 통화',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); _endCall(); },
            child: Text('종료', style: TextStyle(color: AppColors.alarm)),
          ),
        ],
      ),
    );
  }

  // ── 메모 ───────────────────────────────────────────────────────────────────

  void _showMemoDialog() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('메모'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '의심스러운 내용을 기록하세요...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _msgs.add(_Msg(text: '📝 메모: $text', isUser: true));
                });
              }
              Navigator.pop(context);
            },
            child: Text('저장', style: TextStyle(color: AppColors.amber)),
          ),
        ],
      ),
    );
  }

  // ── 증거 선택 ──────────────────────────────────────────────────────────────

  void _showEvidenceDialog() {
    final aiMsgs = _msgs.where((m) => !m.isUser).toList();
    if (aiMsgs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장할 대화 내용이 없습니다.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded, color: AppColors.alarm, size: 18),
                const SizedBox(width: 8),
                Text('증거로 저장할 발언 선택',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: aiMsgs.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.border, height: 1),
              itemBuilder: (_, i) {
                final msg = aiMsgs[i];
                return ListTile(
                  dense: true,
                  leading: msg.danger != null
                      ? const Icon(Icons.warning_rounded,
                          color: AppColors.alarm, size: 18)
                      : const Icon(Icons.circle, color: AppColors.border, size: 8),
                  title: Text(
                    msg.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  onTap: () {
                    setState(() {
                      _msgs.add(_Msg(
                        text: '🔖 증거 저장됨: "${msg.text}"',
                        isUser: true,
                      ));
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('증거가 저장되었습니다.')),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── 의심 신고 ──────────────────────────────────────────────────────────────

  void _reportSuspicion() {
    setState(() {
      _msgs.add(_Msg(text: '🚨 피싱 의심 신고됨 — 통화를 종료합니다.', isUser: true));
    });
    Future.delayed(const Duration(milliseconds: 800), _endCall);
  }

  // ── 키패드 ─────────────────────────────────────────────────────────────────

  void _showKeypad() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _KeypadSheet(),
    );
  }

  // ── 유틸 ───────────────────────────────────────────────────────────────────

  void _scrollLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollCtrl.hasClients) {
        _logScrollCtrl.animateTo(
          _logScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _timerText {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _statusText {
    switch (_state) {
      case _CallState.connecting: return '연결 중...';
      case _CallState.aiSpeaking: return '듣는 중';
      case _CallState.userTurn:   return '마이크를 눌러 말하세요';
      case _CallState.recording:  return '음성 입력 중...';
      case _CallState.processing: return '답변 생성 중...';
      case _CallState.ended:      return '통화 종료';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wsSub?.cancel();
    _channel?.sink.close();
    _player.dispose();
    _recorder.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _logScrollCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSpeaking = _state == _CallState.aiSpeaking;
    final isUserTurn = _state == _CallState.userTurn;
    final isRecording = _state == _CallState.recording;
    final isProcessing = _state == _CallState.processing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── 상단 바 ──────────────────────────────────────────────────────
            _TopBar(
              timer: _timerText,
              isConnecting: _state == _CallState.connecting,
            ),

            // ── 발신자 정보 + 아바타 ─────────────────────────────────────────
            const SizedBox(height: 20),
            _CallerCard(
              caller: _caller,
              pulseAnim: _pulseAnim,
              isSpeaking: isSpeaking,
              statusText: _statusText,
            ),

            // ── 위험 신호 배너 ────────────────────────────────────────────────
            if (_currentDanger.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DangerBanner(text: _currentDanger),
            ],

            // ── 대화 로그 ─────────────────────────────────────────────────────
            const SizedBox(height: 12),
            _LogToggleBar(
              showLog: _showLog,
              msgCount: _msgs.length,
              onToggle: () => setState(() => _showLog = !_showLog),
            ),
            if (_showLog)
              _LogPanel(msgs: _msgs, scrollCtrl: _logScrollCtrl),

            const Spacer(),

            // ── 음성 입력 파형 표시 ──────────────────────────────────────────
            if (isRecording || isProcessing)
              _VoiceStatus(
                isRecording: isRecording,
                waveCtrl: _waveCtrl,
              ),

            const SizedBox(height: 16),

            // ── 피싱 대응 버튼 row ───────────────────────────────────────────
            _PhishingActions(
              onReport: _reportSuspicion,
              onEvidence: _showEvidenceDialog,
              onMemo: _showMemoDialog,
            ),

            const SizedBox(height: 16),

            // ── 통화 기능 버튼 row ────────────────────────────────────────────
            _CallControls(
              isMuted: _isMuted,
              isSpeaker: _isSpeaker,
              isUserTurn: isUserTurn,
              isRecording: isRecording,
              onMuteToggle: () => setState(() => _isMuted = !_isMuted),
              onSpeakerToggle: () => setState(() => _isSpeaker = !_isSpeaker),
              onKeypad: _showKeypad, // ignore: avoid_redundant_argument_values
              onMicDown: _startRecording,
              onMicUp: _stopRecording,
              onEndCall: _confirmEndCall,
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ─── 상단 바 ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.timer, required this.isConnecting});

  final String timer;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.alarm.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Stage 2 · 음성 통화',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.alarm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnecting ? AppColors.amber : AppColors.safe,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isConnecting ? '연결 중' : timer,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 발신자 카드 ──────────────────────────────────────────────────────────────

class _CallerCard extends StatelessWidget {
  const _CallerCard({
    required this.caller,
    required this.pulseAnim,
    required this.isSpeaking,
    required this.statusText,
  });

  final _CallerInfo caller;
  final Animation<double> pulseAnim;
  final bool isSpeaking;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, _) {
            final scale = isSpeaking ? pulseAnim.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSpeaking)
                    Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: caller.accentColor.withValues(alpha: 0.10),
                      ),
                    ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: caller.accentColor.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isSpeaking
                            ? caller.accentColor
                            : AppColors.border,
                        width: isSpeaking ? 2.5 : 1.5,
                      ),
                    ),
                    child: Icon(caller.icon, color: caller.accentColor, size: 42),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Text(caller.name,
            style: textTheme.titleLarge?.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(caller.subtitle,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            statusText,
            style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ─── 위험 신호 배너 ───────────────────────────────────────────────────────────

class _DangerBanner extends StatelessWidget {
  const _DangerBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.alarm.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.alarm.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.alarm, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ 위험 신호 감지: $text',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.alarm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 대화 로그 토글 ───────────────────────────────────────────────────────────

class _LogToggleBar extends StatelessWidget {
  const _LogToggleBar({
    required this.showLog,
    required this.msgCount,
    required this.onToggle,
  });

  final bool showLog;
  final int msgCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              '실시간 대화 기록 ($msgCount)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Icon(
              showLog ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 대화 로그 패널 ───────────────────────────────────────────────────────────

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.msgs, required this.scrollCtrl});

  final List<_Msg> msgs;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 140,
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: msgs.isEmpty
          ? Center(
              child: Text('대화 기록이 없습니다.',
                  style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary)),
            )
          : ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(10),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                final isUser = m.isUser;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? '나 ' : 'AI ',
                        style: textTheme.labelSmall?.copyWith(
                          color: isUser
                              ? AppColors.textSecondary
                              : m.danger != null
                              ? AppColors.alarm
                              : AppColors.amber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          m.text,
                          style: textTheme.bodySmall?.copyWith(
                            color: m.danger != null && !isUser
                                ? AppColors.alarm.withValues(alpha: 0.8)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ─── 음성 입력 상태 표시 ──────────────────────────────────────────────────────

class _VoiceStatus extends StatelessWidget {
  const _VoiceStatus({required this.isRecording, required this.waveCtrl});

  final bool isRecording;
  final AnimationController waveCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isRecording)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => _WaveBar(ctrl: waveCtrl, index: i),
            ),
          )
        else
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.amber,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          isRecording ? '음성 입력 중...' : '답변 생성 중...',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isRecording ? AppColors.safe : AppColors.amber,
          ),
        ),
      ],
    );
  }
}

// ─── 파형 바 ──────────────────────────────────────────────────────────────────

class _WaveBar extends StatelessWidget {
  const _WaveBar({required this.ctrl, required this.index});

  final AnimationController ctrl;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, _) {
        final h = 6.0 + sin((ctrl.value + index * 0.2) * pi) * 18;
        return Container(
          width: 4,
          height: h.clamp(6.0, 24.0),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: AppColors.safe,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

// ─── 피싱 대응 버튼 ───────────────────────────────────────────────────────────

class _PhishingActions extends StatelessWidget {
  const _PhishingActions({
    required this.onReport,
    required this.onEvidence,
    required this.onMemo,
  });

  final VoidCallback onReport;
  final VoidCallback onEvidence;
  final VoidCallback onMemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ActionChip(
              icon: Icons.report_problem_rounded,
              label: '피싱 신고',
              color: AppColors.alarm,
              onTap: onReport,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionChip(
              icon: Icons.bookmark_add_rounded,
              label: '증거 저장',
              color: AppColors.amber,
              onTap: onEvidence,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionChip(
              icon: Icons.edit_note_rounded,
              label: '메모',
              color: AppColors.textSecondary,
              onTap: onMemo,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 통화 기능 버튼 ───────────────────────────────────────────────────────────

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.isMuted,
    required this.isSpeaker,
    required this.isUserTurn,
    required this.isRecording,
    required this.onMuteToggle,
    required this.onSpeakerToggle,
    required this.onKeypad,
    required this.onMicDown,
    required this.onMicUp,
    required this.onEndCall,
  });

  final bool isMuted;
  final bool isSpeaker;
  final bool isUserTurn;
  final bool isRecording;
  final VoidCallback onMuteToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onKeypad;
  final VoidCallback onMicDown;
  final VoidCallback onMicUp;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 보조 버튼 row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CtrlBtn(
                icon: isMuted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
                label: isMuted ? '음소거 해제' : '음소거',
                active: isMuted,
                onTap: onMuteToggle,
              ),
              _CtrlBtn(
                icon: isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                label: '스피커',
                active: isSpeaker,
                onTap: onSpeakerToggle,
              ),
              _CtrlBtn(
                icon: Icons.dialpad_rounded,
                label: '키패드',
                active: false,
                onTap: onKeypad,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 마이크 + 종료 row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 통화 종료
            GestureDetector(
              onTap: onEndCall,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.alarm,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.alarm.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.call_end_rounded,
                    color: AppColors.onAlarm, size: 26),
              ),
            ),
            const SizedBox(width: 32),
            // 마이크 (hold to speak)
            GestureDetector(
              onTapDown: isUserTurn && !isMuted ? (_) => onMicDown() : null,
              onTapUp: isRecording ? (_) => onMicUp() : null,
              onTapCancel: isRecording ? onMicUp : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: isRecording ? 80 : 68,
                height: isRecording ? 80 : 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? AppColors.safe
                      : isUserTurn && !isMuted
                      ? AppColors.surface
                      : AppColors.surfaceAlt,
                  border: Border.all(
                    color: isRecording ? AppColors.safe : AppColors.border,
                    width: isRecording ? 3 : 1.5,
                  ),
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: AppColors.safe.withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: isRecording
                      ? Colors.white
                      : isUserTurn && !isMuted
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppColors.textPrimary.withValues(alpha: 0.15)
                  : AppColors.surface,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 키패드 시트 ──────────────────────────────────────────────────────────────

class _KeypadSheet extends StatelessWidget {
  const _KeypadSheet();

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['*', '0', '#'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('키패드',
              style: Theme.of(context).textTheme.titleSmall),
        ),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 12),
        for (final row in _keys)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((k) => _KeyBtn(label: k)).toList(),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _KeyBtn extends StatelessWidget {
  const _KeyBtn({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 64,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
