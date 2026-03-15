import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:game/features/cards/domain/entities/card.dart';
import 'features/cards/presentation/pages/card_list_page.dart';
import 'features/cards/presentation/pages/card_detail_page.dart';
import 'features/scan/presentation/pages/scan_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/memory_game/presentation/pages/memory_game_page.dart';
import 'features/menu/presentation/pages/main_menu_page.dart';
import 'features/scoreboard/presentation/pages/scoreboard_page.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MainMenuRoute.page, initial: true),
    AutoRoute(page: CardListRoute.page),
    AutoRoute(page: CardDetailRoute.page),
    AutoRoute(page: ScanRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: MemoryGameRoute.page),
    AutoRoute(page: ScoreboardRoute.page),
  ];
}
