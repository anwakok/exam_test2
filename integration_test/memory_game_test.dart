import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  group('End-to-End Memory Game Flow', () {
    setUp(() async {
      // Reset GetIt before each test
      if (getIt.isRegistered<Dio>()) {
        await getIt.reset();
      }
    });
    testWidgets('complete game flow shows login dialog when not logged in', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify main menu is displayed
      expect(find.text('YU-GI-OH!\nMEMORY DUEL'), findsOneWidget);
      expect(find.text('START GAME'), findsOneWidget);

      // Tap START GAME button
      await tester.tap(find.text('START GAME'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify login dialog appears (because game requires login)
      expect(find.text('ต้องเข้าสู่ระบบก่อน'), findsOneWidget);
    });

    testWidgets('navigate to deck and back', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify main menu
      expect(find.text('DECK'), findsOneWidget);

      // Tap DECK button
      await tester.tap(find.text('DECK'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on the Card List page (should show Thai title)
      expect(find.text('คลังการ์ด'), findsOneWidget);

      // Go back using system back (AppBar doesn't have back button, use router)
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're back on main menu
      expect(find.text('YU-GI-OH!\nMEMORY DUEL'), findsOneWidget);
    });

    testWidgets('navigate to scoreboard does nothing when not logged in', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify main menu
      expect(find.text('SCOREBOARD'), findsOneWidget);

      // Tap SCOREBOARD button (does nothing when not logged in)
      await tester.tap(find.text('SCOREBOARD'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify still on main menu (no navigation happened)
      expect(find.text('YU-GI-OH!\nMEMORY DUEL'), findsOneWidget);
    });
  });
}
