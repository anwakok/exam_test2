// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  atk: (json['atk'] as num?)?.toInt(),
  def: (json['def'] as num?)?.toInt(),
  type: json['type'] as String?,
  cardImages: (json['card_images'] as List<dynamic>?)
      ?.map((e) => CardImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  description: json['desc'] as String?,
);

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'atk': instance.atk,
  'def': instance.def,
  'type': instance.type,
  'card_images': instance.cardImages,
  'desc': instance.description,
};

CardImage _$CardImageFromJson(Map<String, dynamic> json) =>
    CardImage(imageUrl: json['image_url'] as String);

Map<String, dynamic> _$CardImageToJson(CardImage instance) => <String, dynamic>{
  'image_url': instance.imageUrl,
};
