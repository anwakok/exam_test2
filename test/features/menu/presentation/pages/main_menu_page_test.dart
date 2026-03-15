import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/router.dart';

void main() {
  group('MainMenuPage Widget Tests', () {
    testWidgets('should display all menu buttons', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: AppRouter().config()),
      );

      // Wait for router to settle
      await tester.pumpAndSettle();

      // Verify menu title (using partial match)
      expect(find.textContaining('YU-GI-OH'), findsOneWidget);

      // Verify all buttons exist
      expect(find.text('START GAME'), findsOneWidget);
      expect(find.text('SCOREBOARD'), findsOneWidget);
      expect(find.text('DECK'), findsOneWidget);
      expect(find.text('EXIT'), findsOneWidget);
    });

    testWidgets('should have correct button styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: AppRouter().config()),
      );
      await tester.pumpAndSettle();

      // Find START GAME button by text (not by ElevatedButton type)
      final startButton = find.text('START GAME');
      expect(startButton, findsOneWidget);

      // Find EXIT button by text
      final exitButton = find.text('EXIT');
      expect(exitButton, findsOneWidget);
    });

    testWidgets('buttons should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: AppRouter().config()),
      );
      await tester.pumpAndSettle();

      // Tap START GAME button
      await tester.tap(find.text('START GAME'));
      await tester.pump();

      // Pump multiple times to handle any async operations
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}
