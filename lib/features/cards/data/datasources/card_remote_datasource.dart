import 'package:dio/dio.dart';
import '../models/card_model.dart';

abstract class CardRemoteDatasource {
  Future<List<CardModel>> getCards();
  Future<CardModel> getCardByName(String name);
}

class CardRemoteDatasourceImpl implements CardRemoteDatasource {
  final Dio dio;

  CardRemoteDatasourceImpl(this.dio);

  @override
  Future<List<CardModel>> getCards() async {
    final response = await dio.get(
      "https://db.ygoprodeck.com/api/v7/cardinfo.php",
    );

    final List data = response.data["data"];

    return data.map((e) => CardModel.fromJson(e)).toList();
  }

  @override
  Future<CardModel> getCardByName(String name) async {
    final response = await dio.get(
      "https://db.ygoprodeck.com/api/v7/cardinfo.php",
      queryParameters: {"name": name},
    );

    final List data = response.data["data"];
    return CardModel.fromJson(data.first);
  }
}
