import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:game/core/error/failures.dart';
import 'package:game/core/usecases/usecase.dart';
import 'package:game/features/cards/domain/entities/card.dart';
import 'package:game/features/cards/domain/repositories/card_repository.dart';
import 'package:game/features/cards/domain/usecases/get_cards.dart';

// Mock repository
class MockCardRepository extends Mock implements CardRepository {}

void main() {
  late GetCards usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = GetCards(mockRepository);
  });

  final tCards = [
    const Card(id: 1, name: 'Blue-Eyes White Dragon', atk: 3000, def: 2500),
    const Card(id: 2, name: 'Dark Magician', atk: 2500, def: 2100),
  ];

  group('GetCards UseCase', () {
    test('should return list of cards from repository', () async {
      // Arrange
      when(
        () => mockRepository.getCards(),
      ).thenAnswer((_) async => Right(tCards));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Right(tCards));
      verify(() => mockRepository.getCards()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.getCards(),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Left(ServerFailure('Server error')));
      verify(() => mockRepository.getCards()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when cache error occurs', () async {
      // Arrange
      when(
        () => mockRepository.getCards(),
      ).thenAnswer((_) async => Left(CacheFailure('Cache error')));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Left(CacheFailure('Cache error')));
      verify(() => mockRepository.getCards()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
