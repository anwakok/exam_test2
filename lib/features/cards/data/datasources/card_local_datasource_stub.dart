// Stub implementation for web - sqflite is not supported on web
import 'package:game/features/cards/data/models/card_model.dart';
import 'package:game/features/cards/domain/entities/card.dart' as domain;

abstract class CardLocalDatasource {
  Future<List<domain.Card>> getCards();
  Future<domain.Card?> getCardById(int id);
  Future<void> insertCard(CardModel card);
  Future<void> insertCards(List<CardModel> cards);
  Future<void> clearCards();
}

class CardLocalDatasourceImpl implements CardLocalDatasource {
  final List<domain.Card> _cards = [];

  @override
  Future<List<domain.Card>> getCards() async {
    return List.from(_cards);
  }

  @override
  Future<domain.Card?> getCardById(int id) async {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> insertCard(CardModel card) async {
    _cards.removeWhere((c) => c.id == card.id);
    _cards.add(card.toEntity());
  }

  @override
  Future<void> insertCards(List<CardModel> cards) async {
    for (final card in cards) {
      await insertCard(card);
    }
  }

  @override
  Future<void> clearCards() async {
    _cards.clear();
  }
}
