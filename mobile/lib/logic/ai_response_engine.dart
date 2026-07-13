import '../models/scenario.dart';

class AiTurnResult {
  const AiTurnResult({required this.line, required this.consumedScript});

  final AiLine line;
  final bool consumedScript;
}

const _angryKeywords = ['뭐래', '장난하지', '미쳤', '짜증', '어이없', '그만해', '헛소리'];

const _refusalKeywords = [
  '안돼',
  '안 돼',
  '싫어',
  '못해',
  '못 해',
  '안할래',
  '안 할래',
  '거절',
  '안보내',
  '안 보내',
  '싫다',
];

const _suspicionKeywords = [
  '사기',
  '피싱',
  '보이스피싱',
  '의심',
  '수상',
  '신고',
  '경찰',
  '가짜',
  '거짓말',
];

const _verifyKeywords = [
  '직접 확인',
  '공식 앱',
  '공식 번호',
  '공식 홈페이지',
  '다시 걸어',
  '검색해서',
  '114',
  '전화해볼게',
  '알아볼게',
  '찾아볼게',
];

bool _matchesAny(String text, List<String> keywords) {
  return keywords.any((keyword) => text.contains(keyword));
}

/// 사용자가 채팅창에 자유롭게 입력한 메시지를 규칙 기반으로 분류한다.
///
/// LLM이 없는 상태에서 최대한 다양한 반응을 끌어내기 위한 절충안 — 우선순위:
/// 화남 > 거절 > 의심 > 직접 확인 시도 > (기본) 순응.
ChatBranch classifyUserMessage(String text) {
  if (_matchesAny(text, _angryKeywords)) return ChatBranch.angry;
  if (_matchesAny(text, _refusalKeywords)) return ChatBranch.refusal;
  if (_matchesAny(text, _suspicionKeywords)) return ChatBranch.suspicious;
  if (_matchesAny(text, _verifyKeywords)) return ChatBranch.verify;
  return ChatBranch.comply;
}

/// 사용자가 고른 선택지(branch)에 대한 AI(사기범 페르소나)의 다음 응답을 결정하는 인터페이스.
///
/// 지금은 [ScriptedAiResponseEngine]만 존재하지만, 백엔드에 LLM 프록시가
/// 생기면 [LlmAiResponseEngine]으로 교체해 ChatScreen 쪽 코드 변경 없이
/// 실제 자유 대화로 전환할 수 있도록 분리해둔다.
abstract class AiResponseEngine {
  Future<AiTurnResult> respond({
    required Scenario scenario,
    required ChatBranch branch,
    required int scriptIndex,
    required int turnIndex,
  });
}

class ScriptedAiResponseEngine implements AiResponseEngine {
  const ScriptedAiResponseEngine();

  @override
  Future<AiTurnResult> respond({
    required Scenario scenario,
    required ChatBranch branch,
    required int scriptIndex,
    required int turnIndex,
  }) async {
    switch (branch) {
      case ChatBranch.suspicious:
        return AiTurnResult(
          line: AiLine(scenario.suspicionResponseFor(turnIndex)),
          consumedScript: false,
        );
      case ChatBranch.refusal:
        return AiTurnResult(
          line: AiLine(scenario.refusalResponseFor(turnIndex)),
          consumedScript: false,
        );
      case ChatBranch.verify:
        return AiTurnResult(
          line: AiLine(scenario.verifyResponseFor(turnIndex)),
          consumedScript: false,
        );
      case ChatBranch.angry:
        return AiTurnResult(
          line: AiLine(scenario.angryResponseFor(turnIndex)),
          consumedScript: false,
        );
      case ChatBranch.comply:
        final responses = scenario.aiResponses;
        final line = scriptIndex < responses.length
            ? responses[scriptIndex]
            : scenario.aiFallbackResponse;
        return AiTurnResult(line: line, consumedScript: true);
    }
  }
}

/// 추후 백엔드의 LLM 프록시(OpenAI 등)와 연동할 자리.
///
/// 클라이언트에 API 키를 직접 넣지 않고, 백엔드가 프롬프트(범죄자 페르소나 +
/// 시나리오 컨텍스트 + 대화 기록)를 조립해 LLM을 호출하도록 위임하는 구조를
/// 전제로 한다. 지금은 백엔드가 없어 미구현 상태로 둔다.
class LlmAiResponseEngine implements AiResponseEngine {
  const LlmAiResponseEngine();

  @override
  Future<AiTurnResult> respond({
    required Scenario scenario,
    required ChatBranch branch,
    required int scriptIndex,
    required int turnIndex,
  }) {
    throw UnimplementedError(
      'LLM 기반 응답은 아직 연동되지 않았습니다. 백엔드의 채팅 API(POST /api/v1/chat/{record_id}/send)가 '
      '준비되면 이 클래스에서 해당 API를 호출하도록 구현하세요.',
    );
  }
}
