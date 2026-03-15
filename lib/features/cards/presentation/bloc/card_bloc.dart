import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/core/usecases/usecase.dart';
import 'package:game/features/cards/domain/usecases/get_cards.dart';
import 'card_event.dart';

export 'card_event.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final GetCards getCards;

  CardBloc(this.getCards) : super(const CardInitial()) {
    on<LoadCards>(_onLoadCards);
    on<RefreshCards>(_onRefreshCards);
  }

  Future<void> _onLoadCards(LoadCards event, Emitter<CardState> emit) async {
    emit(const CardLoading());

    final result = await getCards(const NoParams());

    result.fold(
      (failure) => emit(CardError(failure.message)),
      (cards) => emit(CardLoaded(cards)),
    );
  }

  Future<void> _onRefreshCards(
    RefreshCards event,
    Emitter<CardState> emit,
  ) async {
    emit(const CardLoading());

    final result = await getCards(const NoParams());

    result.fold(
      (failure) => emit(CardError(failure.message)),
      (cards) => emit(CardLoaded(cards)),
    );
  }
}
