class MemoryGame {
  List<int> cards = [];
  List<bool> flipped = [];
  List<bool> matched = [];
  int? firstIndex;
  int moves = 0;
  int matches = 0;

  void initialize(int pairs) {
    cards = [];
    for (int i = 0; i < pairs; i++) {
      cards.add(i);
      cards.add(i);
    }
    cards.shuffle();
    flipped = List.filled(cards.length, false);
    matched = List.filled(cards.length, false);
    firstIndex = null;
    moves = 0;
    matches = 0;
  }

  void flip(int index) {
    if (flipped[index] || matched[index]) return;

    flipped[index] = true;

    if (firstIndex == null) {
      firstIndex = index;
    } else {
      moves++;
      if (cards[firstIndex!] == cards[index]) {
        matched[firstIndex!] = true;
        matched[index] = true;
        matches++;
        firstIndex = null;
      }
    }
  }

  void unflip() {
    if (firstIndex != null) {
      for (int i = 0; i < flipped.length; i++) {
        if (!matched[i]) {
          flipped[i] = false;
        }
      }
      firstIndex = null;
    }
  }

  bool isComplete() {
    return matches == cards.length ~/ 2;
  }
}
