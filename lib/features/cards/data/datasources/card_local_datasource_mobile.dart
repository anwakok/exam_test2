import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:game/features/cards/data/models/card_model.dart';
import 'package:game/features/cards/domain/entities/card.dart' as domain;

abstract class CardLocalDatasource {
  Future<List<domain.Card>> getCards();
  Future<domain.Card?> getCardById(int id);
  Future<void> insertCard(CardModel card);
  Future<void> insertCards(List<CardModel> cards);
  Future<void> clearCards();
}

class CardLocalDatasourceImpl implements CardLocalDatasource {
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yugioh_cards.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY,
            name TEXT,
            atk INTEGER,
            def INTEGER,
            imageUrl TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<List<domain.Card>> getCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards');

    return List.generate(maps.length, (i) {
      return domain.Card(
        id: maps[i]['id'],
        name: maps[i]['name'],
        atk: maps[i]['atk'],
        def: maps[i]['def'],
        imageUrl: maps[i]['imageUrl'],
        description: maps[i]['description'],
      );
    });
  }

  @override
  Future<domain.Card?> getCardById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return domain.Card(
      id: maps.first['id'],
      name: maps.first['name'],
      atk: maps.first['atk'],
      def: maps.first['def'],
      imageUrl: maps.first['imageUrl'],
      description: maps.first['description'],
    );
  }

  @override
  Future<void> insertCard(CardModel card) async {
    final db = await database;
    await db.insert('cards', {
      'id': card.id,
      'name': card.name,
      'atk': card.atk,
      'def': card.def,
      'imageUrl': card.cardImages?.first.imageUrl,
      'description': card.description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> insertCards(List<CardModel> cards) async {
    final db = await database;
    final batch = db.batch();

    for (final card in cards) {
      batch.insert('cards', {
        'id': card.id,
        'name': card.name,
        'atk': card.atk,
        'def': card.def,
        'imageUrl': card.cardImages?.first.imageUrl,
        'description': card.description,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> clearCards() async {
    final db = await database;
    await db.delete('cards');
  }
}
