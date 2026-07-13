import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phising_defense/main.dart';

void main() {
  testWidgets('로그인 화면이 첫 화면으로 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());

    expect(find.text('피싱 디펜스'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('로그인하면 시나리오 선택 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    expect(find.text('어떤 상황을 훈련해볼까요?'), findsOneWidget);
    expect(find.text('검찰 사칭'), findsOneWidget);
  });
}
