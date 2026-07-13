import '../models/scenario.dart';

class AiTurnResult {
  const AiTurnResult({required this.message, required this.consumedScript});

  final String message;
  final bool consumedScript;
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
          message: scenario.suspicionResponseFor(turnIndex),
          consumedScript: false,
        );
      case ChatBranch.refusal:
        return AiTurnResult(
          message: scenario.refusalResponseFor(turnIndex),
          consumedScript: false,
        );
      case ChatBranch.comply:
        final responses = scenario.aiResponses;
        final message = scriptIndex < responses.length
            ? responses[scriptIndex]
            : scenario.aiFallbackResponse;
        return AiTurnResult(message: message, consumedScript: true);
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
