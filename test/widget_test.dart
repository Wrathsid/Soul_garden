// Basic Flutter widget test for SoulGarden app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soul_garden/features/garden/presentation/garden_screen.dart';

void main() {
  testWidgets('Garden screen shows greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: GardenScreen())));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.textContaining('Good'), findsOneWidget);
  });
}
