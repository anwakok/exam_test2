import 'package:equatable/equatable.dart';
import 'package:game/features/cards/domain/entities/card.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object> get props => [];
}

class LoadCards extends CardEvent {
  const LoadCards();
}

class RefreshCards extends CardEvent {
  const RefreshCards();
}

abstract class CardState extends Equatable {
  const CardState();

  @override
  List<Object> get props => [];
}

class CardInitial extends CardState {
  const CardInitial();
}

class CardLoading extends CardState {
  const CardLoading();
}

class CardLoaded extends CardState {
  final List<Card> cards;

  const CardLoaded(this.cards);

  @override
  List<Object> get props => [cards];
}

class CardError extends CardState {
  final String message;

  const CardError(this.message);

  @override
  List<Object> get props => [message];
}
