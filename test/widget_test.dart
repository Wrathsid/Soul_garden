// Basic Flutter widget test for SoulGarden app.

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_garden/main.dart';

void main() {
  testWidgets('SoulGarden app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SoulGardenApp());

    // Verify that the app launches (basic smoke test)
    expect(find.text('Garden'), findsOneWidget);
  });
}
