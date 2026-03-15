import 'package:dartz/dartz.dart';
import 'package:game/core/error/failures.dart';
import 'package:game/core/usecases/usecase.dart';
import 'package:game/features/cards/domain/entities/card.dart';
import 'package:game/features/cards/domain/repositories/card_repository.dart';

class GetCards implements UseCase<List<Card>, NoParams> {
  final CardRepository repository;

  GetCards(this.repository);

  @override
  Future<Either<Failure, List<Card>>> call(NoParams params) async {
    return await repository.getCards();
  }
}
