import 'package:equatable/equatable.dart';
import 'package:game/features/cards/domain/entities/card.dart' as yugi;

abstract class DuelEvent extends Equatable {
  const DuelEvent();

  @override
  List<Object> get props => [];
}

class StartDuel extends DuelEvent {
  final List<yugi.Card> playerDeck;
  final List<yugi.Card> enemyDeck;

  const StartDuel({required this.playerDeck, required this.enemyDeck});

  @override
  List<Object> get props => [playerDeck, enemyDeck];
}

class Attack extends DuelEvent {
  final int atk;

  const Attack(this.atk);

  @override
  List<Object> get props => [atk];
}

class NextTurn extends DuelEvent {
  const NextTurn();
}

class EndDuel extends DuelEvent {
  const EndDuel();
}

abstract class DuelState extends Equatable {
  const DuelState();

  @override
  List<Object> get props => [];
}

class DuelInitial extends DuelState {
  const DuelInitial();
}

class DuelInProgress extends DuelState {
  final int playerLP;
  final int enemyLP;
  final int turn;
  final bool playerTurn;
  final List<yugi.Card> playerField;
  final List<yugi.Card> enemyField;
  final List<yugi.Card> playerHand;

  const DuelInProgress({
    required this.playerLP,
    required this.enemyLP,
    required this.turn,
    required this.playerTurn,
    required this.playerField,
    required this.enemyField,
    required this.playerHand,
  });

  @override
  List<Object> get props => [
    playerLP,
    enemyLP,
    turn,
    playerTurn,
    playerField,
    enemyField,
    playerHand,
  ];
}

class DuelEnded extends DuelState {
  final String winner;

  const DuelEnded(this.winner);

  @override
  List<Object> get props => [winner];
}
