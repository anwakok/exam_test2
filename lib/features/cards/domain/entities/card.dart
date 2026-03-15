import 'package:equatable/equatable.dart';

class Card extends Equatable {
  final int id;
  final String name;
  final int atk;
  final int def;
  final String? imageUrl;
  final String? description;
  final String? type;

  const Card({
    required this.id,
    required this.name,
    required this.atk,
    required this.def,
    this.imageUrl,
    this.description,
    this.type,
  });

  @override
  List<Object?> get props => [id, name, atk, def, imageUrl, description, type];

  // Helper method to check if card is a monster card
  bool get isMonsterCard => type?.toLowerCase().contains('monster') ?? false;
}
