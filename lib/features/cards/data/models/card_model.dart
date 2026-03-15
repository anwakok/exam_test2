import 'package:json_annotation/json_annotation.dart';
import 'package:game/features/cards/domain/entities/card.dart' as domain;

part 'card_model.g.dart';

@JsonSerializable()
class CardModel {
  final int id;
  final String name;
  final int? atk;
  final int? def;
  final String? type;
  @JsonKey(name: 'card_images')
  final List<CardImage>? cardImages;
  @JsonKey(name: 'desc')
  final String? description;

  CardModel({
    required this.id,
    required this.name,
    this.atk,
    this.def,
    this.type,
    this.cardImages,
    this.description,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  domain.Card toEntity() => domain.Card(
    id: id,
    name: name,
    atk: atk ?? 0,
    def: def ?? 0,
    type: type,
    imageUrl: cardImages?.first.imageUrl,
    description: description,
  );

  factory CardModel.fromEntity(domain.Card card) => CardModel(
    id: card.id,
    name: card.name,
    atk: card.atk,
    def: card.def,
    type: card.type,
    description: card.description,
    cardImages: card.imageUrl != null
        ? [CardImage(imageUrl: card.imageUrl!)]
        : null,
  );
}

@JsonSerializable()
class CardImage {
  @JsonKey(name: 'image_url')
  final String imageUrl;

  CardImage({required this.imageUrl});

  factory CardImage.fromJson(Map<String, dynamic> json) =>
      _$CardImageFromJson(json);

  Map<String, dynamic> toJson() => _$CardImageToJson(this);
}
