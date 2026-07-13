import 'package:flutter_test/flutter_test.dart';

import 'package:phising_defense/main.dart';

void main() {
  testWidgets('시나리오 선택 화면이 첫 화면으로 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const PhishingDefenseApp());

    expect(find.text('어떤 상황을 훈련해볼까요?'), findsOneWidget);
    expect(find.text('검찰 사칭'), findsOneWidget);
  });
}
