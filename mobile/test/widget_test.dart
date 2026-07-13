import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phising_defense/main.dart';

void main() {
  testWidgets('로그인 화면이 첫 화면으로 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());

    expect(find.text('피싱 디펜스'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('입력값이 비어 있으면 로그인이 진행되지 않는다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());

    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pump();

    expect(find.text('이메일과 비밀번호를 입력해주세요.'), findsOneWidget);
  });

  testWidgets('로그인 요청이 실패하면 오류 메시지를 보여준다', (WidgetTester tester) async {
    // 위젯 테스트 환경에서는 실제 네트워크 요청 대신 항상 400 응답으로
    // 대체되므로(TestWidgetsFlutterBinding), 로그인 실패 경로만 검증한다.
    await tester.pumpWidget(const PhishingDefenseApp());

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    expect(find.text('이메일 또는 비밀번호가 올바르지 않습니다.'), findsOneWidget);
  });
}
