import 'package:game/features/cards/domain/entities/card.dart' as yugi;

class DuelEngine {
  int playerLP = 4000;
  int enemyLP = 4000;
  int turn = 1;
  bool playerTurn = true;

  List<yugi.Card> playerField = [];
  List<yugi.Card> enemyField = [];
  List<yugi.Card> playerHand = [];
  List<yugi.Card> enemyHand = [];

  void nextTurn() {
    playerTurn = !playerTurn;
    turn++;
  }

  void attack(int atk) {
    if (playerTurn) {
      enemyLP -= atk;
    } else {
      playerLP -= atk;
    }
    nextTurn();
  }

  bool checkWinner() {
    if (playerLP <= 0 || enemyLP <= 0) {
      return true;
    }
    return false;
  }

  String? getWinner() {
    if (playerLP <= 0) return 'Enemy';
    if (enemyLP <= 0) return 'Player';
    return null;
  }

  void reset() {
    playerLP = 4000;
    enemyLP = 4000;
    turn = 1;
    playerTurn = true;
    playerField = [];
    enemyField = [];
    playerHand = [];
    enemyHand = [];
  }
}
