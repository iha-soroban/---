import 'package:flutter_test/flutter_test.dart';

import 'package:flash_calc/main.dart';

void main() {
  testWidgets('Flash Calc app launches and shows home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('FLASH CALC'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });
}
