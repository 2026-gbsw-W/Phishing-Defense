import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:phising_defense/main.dart';

void main() {
  setUp(() {
    // 저장된 세션이 없는 상태(로그아웃 상태)로 시작해 AuthGate가 로그인
    // 화면을 보여주도록 한다.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('세션이 없으면 로그인 화면이 첫 화면으로 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    expect(find.text('피싱 디펜스'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('입력값이 비어 있으면 로그인이 진행되지 않는다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pump();

    expect(find.text('이메일과 비밀번호를 입력해주세요.'), findsOneWidget);
  });

  testWidgets('로그인 요청이 실패하면 오류 메시지를 보여준다', (WidgetTester tester) async {
    // 위젯 테스트 환경에서는 실제 네트워크 요청 대신 항상 400 응답으로
    // 대체되므로(TestWidgetsFlutterBinding), 로그인 실패 경로만 검증한다.
    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    expect(find.text('이메일 또는 비밀번호가 올바르지 않습니다.'), findsOneWidget);
  });

  testWidgets('회원가입 링크를 누르면 회원가입 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('계정이 없으신가요? 회원가입'));
    await tester.pumpAndSettle();

    expect(find.text('회원가입'), findsWidgets);
    expect(find.text('피싱 디펜스와 함께 훈련을 시작해보세요.'), findsOneWidget);
  });

  testWidgets('세션이 저장되어 있으면 로그인 화면을 건너뛴다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.accessToken': 'token',
      'auth.refreshToken': 'refresh',
      'auth.userId': 1,
      'auth.email': 'test@example.com',
      'auth.nickname': '테스터',
      'auth.level': 1,
    });

    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    // 위젯 테스트 환경에서는 실제 네트워크 요청이 항상 실패하므로
    // (TestWidgetsFlutterBinding), 로그인 화면을 건너뛰고 시나리오 선택
    // 화면(로그아웃 버튼이 있는 AppBar)까지 도달했는지만 확인한다.
    expect(find.byTooltip('로그아웃'), findsOneWidget);
    expect(find.text('로그인'), findsNothing);
  });

  testWidgets('로그아웃하면 로그인 화면으로 돌아간다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.accessToken': 'token',
      'auth.refreshToken': 'refresh',
      'auth.userId': 1,
      'auth.email': 'test@example.com',
      'auth.nickname': '테스터',
      'auth.level': 1,
    });

    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('로그아웃'));
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('전에 로그인한 이메일이 있으면 자동으로 채워진다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'auth.lastEmail': 'remembered@example.com',
    });

    await tester.pumpWidget(const PhishingDefenseApp());
    await tester.pumpAndSettle();

    final emailField = tester.widget<TextField>(find.byType(TextField).first);
    expect(emailField.controller?.text, 'remembered@example.com');
  });
}
