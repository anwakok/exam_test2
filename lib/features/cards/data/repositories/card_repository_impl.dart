import 'package:dartz/dartz.dart';
import 'package:game/core/error/failures.dart';
import 'package:game/features/cards/domain/entities/card.dart';
import 'package:game/features/cards/domain/repositories/card_repository.dart';
import '../datasources/card_local_datasource.dart';
import '../datasources/card_remote_datasource.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDatasource remote;
  final CardLocalDatasource local;

  CardRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<Card>>> getCards() async {
    try {
      // Always try to get local cards first (for offline support)
      final localCards = await local.getCards();

      if (localCards.isNotEmpty) {
        // Return cached cards immediately
        return Right(localCards);
      }

      // If no local cache, try to fetch from remote
      try {
        final remoteCards = await remote.getCards();
        await local.insertCards(remoteCards);
        return Right(remoteCards.map((e) => e.toEntity()).toList());
      } catch (networkError) {
        // Network failed and no local cache
        return Left(
          NetworkFailure(
            'ไม่มีการเชื่อมต่ออินเทอร์เน็ต และไม่มีข้อมูลการ์ดในเครื่อง '
            'กรุณาเชื่อมต่ออินเทอร์เน็ตครั้งแรกเพื่อโหลดข้อมูลการ์ด',
          ),
        );
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Card?>> getCardById(int id) async {
    try {
      final localCard = await local.getCardById(id);
      return Right(localCard);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Card>> getCardByName(String name) async {
    try {
      final remoteCard = await remote.getCardByName(name);
      await local.insertCard(remoteCard);
      return Right(remoteCard.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
