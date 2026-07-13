import 'package:flutter_test/flutter_test.dart';
import 'package:phising_defense/logic/ai_response_engine.dart';
import 'package:phising_defense/models/scenario.dart';

void main() {
  group('classifyUserMessage', () {
    test('공백이 달라도 같은 분류로 인식한다', () {
      expect(classifyUserMessage('안돼'), ChatBranch.refusal);
      expect(classifyUserMessage('안 돼'), ChatBranch.refusal);
    });

    test('화남 키워드를 감지한다', () {
      expect(classifyUserMessage('아 뭐래 진짜'), ChatBranch.angry);
      expect(classifyUserMessage('장난해?'), ChatBranch.angry);
    });

    test('거절 키워드를 감지한다', () {
      expect(classifyUserMessage('그건 못해줘'), ChatBranch.refusal);
      expect(classifyUserMessage('필요 없어'), ChatBranch.refusal);
    });

    test('의심 키워드를 감지한다', () {
      expect(classifyUserMessage('이거 사기 아니야?'), ChatBranch.suspicious);
      expect(classifyUserMessage('좀 이상한데'), ChatBranch.suspicious);
    });

    test('직접 확인 시도 키워드를 감지한다', () {
      expect(classifyUserMessage('공식 앱으로 확인해볼게'), ChatBranch.verify);
      expect(classifyUserMessage('대표번호로 전화해볼게'), ChatBranch.verify);
    });

    test('아무 키워드도 없으면 순응으로 분류한다', () {
      expect(classifyUserMessage('네 알겠습니다'), ChatBranch.comply);
    });

    test('여러 키워드가 섞이면 화남 > 거절 > 의심 > 확인 순으로 우선한다', () {
      expect(classifyUserMessage('이거 사기 아니야? 안 보내'), ChatBranch.refusal);
      expect(classifyUserMessage('사기 같아서 신고할까 생각중'), ChatBranch.suspicious);
    });
  });
}
