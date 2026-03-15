import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  group('Yu-Gi-Oh Memory Game Integration Tests', () {
    setUp(() async {
      // Reset GetIt before each test
      if (getIt.isRegistered<Dio>()) {
        await getIt.reset();
      }
    });

    testWidgets('Open App -> Main Menu loads', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu opens with correct title and buttons
      expect(find.text('YU-GI-OH!\nMEMORY DUEL'), findsOneWidget);
      expect(find.text('START GAME'), findsOneWidget);
      expect(find.text('SCOREBOARD'), findsOneWidget);
      expect(find.text('DECK'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Navigate to Deck -> Card List loads', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap DECK button
      await tester.tap(find.text('DECK'));
      await tester.pumpAndSettle();

      // Verify CardListPage opened with Thai title
      expect(find.text('คลังการ์ด'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Navigate to Scoreboard does nothing when not logged in', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap SCOREBOARD button (does nothing when not logged in)
      await tester.tap(find.text('SCOREBOARD'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify still on main menu (no navigation happened)
      expect(find.text('YU-GI-OH!\nMEMORY DUEL'), findsOneWidget);
    });

    testWidgets('Navigate to Play -> shows login dialog when not logged in', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap START GAME button
      await tester.tap(find.text('START GAME'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify login dialog appears (title in Thai)
      expect(find.text('ต้องเข้าสู่ระบบก่อน'), findsOneWidget);
    });
  });
}
