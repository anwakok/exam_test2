import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/features/duel/game_engine.dart';
import 'package:game/features/duel/duel_event.dart';

export 'package:game/features/duel/duel_event.dart';

class DuelBloc extends Bloc<DuelEvent, DuelState> {
  final DuelEngine _duelEngine = DuelEngine();

  DuelBloc() : super(const DuelInitial()) {
    on<StartDuel>(_onStartDuel);
    on<Attack>(_onAttack);
    on<NextTurn>(_onNextTurn);
    on<EndDuel>(_onEndDuel);
  }

  void _onStartDuel(StartDuel event, Emitter<DuelState> emit) {
    _duelEngine.reset();
    _duelEngine.playerHand = event.playerDeck.take(5).toList();
    _duelEngine.enemyHand = event.enemyDeck.take(5).toList();
    emit(
      DuelInProgress(
        playerLP: _duelEngine.playerLP,
        enemyLP: _duelEngine.enemyLP,
        turn: _duelEngine.turn,
        playerTurn: _duelEngine.playerTurn,
        playerField: _duelEngine.playerField,
        enemyField: _duelEngine.enemyField,
        playerHand: _duelEngine.playerHand,
      ),
    );
  }

  void _onAttack(Attack event, Emitter<DuelState> emit) {
    _duelEngine.attack(event.atk);

    if (_duelEngine.checkWinner()) {
      emit(DuelEnded(_duelEngine.getWinner()!));
    } else {
      emit(
        DuelInProgress(
          playerLP: _duelEngine.playerLP,
          enemyLP: _duelEngine.enemyLP,
          turn: _duelEngine.turn,
          playerTurn: _duelEngine.playerTurn,
          playerField: _duelEngine.playerField,
          enemyField: _duelEngine.enemyField,
          playerHand: _duelEngine.playerHand,
        ),
      );
    }
  }

  void _onNextTurn(NextTurn event, Emitter<DuelState> emit) {
    _duelEngine.nextTurn();
    emit(
      DuelInProgress(
        playerLP: _duelEngine.playerLP,
        enemyLP: _duelEngine.enemyLP,
        turn: _duelEngine.turn,
        playerTurn: _duelEngine.playerTurn,
        playerField: _duelEngine.playerField,
        enemyField: _duelEngine.enemyField,
        playerHand: _duelEngine.playerHand,
      ),
    );
  }

  void _onEndDuel(EndDuel event, Emitter<DuelState> emit) {
    emit(const DuelInitial());
  }
}
