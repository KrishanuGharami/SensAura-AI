import 'package:flutter_test/flutter_test.dart';
import 'package:sensaura_ai/main.dart';

void main() {
  testWidgets('SensAura AI UI Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const SensAuraApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify top status elements
    expect(find.text('SensAura AI'), findsOneWidget);
    expect(find.text('LOCAL'), findsOneWidget);
    expect(find.text('SENSOR STREAM'), findsOneWidget);
    expect(find.text('BLE CONNECTED'), findsOneWidget);

    // Verify suggested automation card
    expect(find.text('SUGGESTED AUTOMATION'), findsOneWidget);
    expect(find.text('APPLY SCENE'), findsOneWidget);

    // Verify simulation deck
    expect(find.text('DEMO SCENARIO INJECTION'), findsOneWidget);
    expect(find.text('RELAXATION'), findsOneWidget);
    expect(find.text('LEAVING'), findsOneWidget);
  });
}
