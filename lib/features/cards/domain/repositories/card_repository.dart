import 'package:dartz/dartz.dart';
import 'package:game/core/error/failures.dart';
import '../entities/card.dart';

abstract class CardRepository {
  Future<Either<Failure, List<Card>>> getCards();
  Future<Either<Failure, Card?>> getCardById(int id);
  Future<Either<Failure, Card>> getCardByName(String name);
}
