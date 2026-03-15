// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [CardDetailPage]
class CardDetailRoute extends PageRouteInfo<CardDetailRouteArgs> {
  CardDetailRoute({Key? key, required Card card, List<PageRouteInfo>? children})
    : super(
        CardDetailRoute.name,
        args: CardDetailRouteArgs(key: key, card: card),
        initialChildren: children,
      );

  static const String name = 'CardDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CardDetailRouteArgs>();
      return CardDetailPage(key: args.key, card: args.card);
    },
  );
}

class CardDetailRouteArgs {
  const CardDetailRouteArgs({this.key, required this.card});

  final Key? key;

  final Card card;

  @override
  String toString() {
    return 'CardDetailRouteArgs{key: $key, card: $card}';
  }
}

/// generated route for
/// [CardListPage]
class CardListRoute extends PageRouteInfo<void> {
  const CardListRoute({List<PageRouteInfo>? children})
    : super(CardListRoute.name, initialChildren: children);

  static const String name = 'CardListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CardListPage();
    },
  );
}

/// generated route for
/// [MainMenuPage]
class MainMenuRoute extends PageRouteInfo<void> {
  const MainMenuRoute({List<PageRouteInfo>? children})
    : super(MainMenuRoute.name, initialChildren: children);

  static const String name = 'MainMenuRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainMenuPage();
    },
  );
}

/// generated route for
/// [MemoryGamePage]
class MemoryGameRoute extends PageRouteInfo<void> {
  const MemoryGameRoute({List<PageRouteInfo>? children})
    : super(MemoryGameRoute.name, initialChildren: children);

  static const String name = 'MemoryGameRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MemoryGamePage();
    },
  );
}

/// generated route for
/// [ScanPage]
class ScanRoute extends PageRouteInfo<void> {
  const ScanRoute({List<PageRouteInfo>? children})
    : super(ScanRoute.name, initialChildren: children);

  static const String name = 'ScanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScanPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [ScoreboardPage]
class ScoreboardRoute extends PageRouteInfo<void> {
  const ScoreboardRoute({List<PageRouteInfo>? children})
    : super(ScoreboardRoute.name, initialChildren: children);

  static const String name = 'ScoreboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScoreboardPage();
    },
  );
}
