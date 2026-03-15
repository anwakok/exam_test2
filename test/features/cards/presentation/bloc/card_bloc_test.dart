import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:game/core/error/failures.dart';
import 'package:game/core/usecases/usecase.dart';
import 'package:game/features/cards/domain/entities/card.dart';
import 'package:game/features/cards/domain/usecases/get_cards.dart';
import 'package:game/features/cards/presentation/bloc/card_bloc.dart';

class MockGetCards extends Mock implements GetCards {}

void main() {
  setUpAll(() {
    // Register NoParams fallback for mocktail
    registerFallbackValue(NoParams());
  });

  late CardBloc bloc;
  late MockGetCards mockGetCards;

  setUp(() {
    mockGetCards = MockGetCards();
    bloc = CardBloc(mockGetCards);
  });

  tearDown(() {
    bloc.close();
  });

  final tCards = [
    const Card(id: 1, name: 'Blue-Eyes White Dragon', atk: 3000, def: 2500),
    const Card(id: 2, name: 'Dark Magician', atk: 2500, def: 2100),
  ];

  group('CardBloc', () {
    test('initial state should be CardInitial', () {
      expect(bloc.state, equals(const CardInitial()));
    });

    blocTest<CardBloc, CardState>(
      'emits [CardLoading, CardLoaded] when LoadCards is successful',
      build: () {
        when(() => mockGetCards(any())).thenAnswer((_) async => Right(tCards));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCards()),
      expect: () => [const CardLoading(), CardLoaded(tCards)],
      verify: (_) {
        verify(() => mockGetCards(const NoParams())).called(1);
      },
    );

    blocTest<CardBloc, CardState>(
      'emits [CardLoading, CardError] when LoadCards fails with ServerFailure',
      build: () {
        when(
          () => mockGetCards(any()),
        ).thenAnswer((_) async => Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCards()),
      expect: () => [const CardLoading(), const CardError('Server error')],
    );

    blocTest<CardBloc, CardState>(
      'emits [CardLoading, CardError] when LoadCards fails with CacheFailure',
      build: () {
        when(
          () => mockGetCards(any()),
        ).thenAnswer((_) async => Left(CacheFailure('Cache error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCards()),
      expect: () => [const CardLoading(), const CardError('Cache error')],
    );

    blocTest<CardBloc, CardState>(
      'emits [CardLoading, CardError] with default message for unknown failure',
      build: () {
        when(
          () => mockGetCards(any()),
        ).thenAnswer((_) async => Left(NetworkFailure('Network error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCards()),
      expect: () => [const CardLoading(), const CardError('Network error')],
    );
  });
}
