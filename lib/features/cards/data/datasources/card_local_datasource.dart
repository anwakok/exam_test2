import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:game/features/cards/data/models/card_model.dart';
import 'package:game/features/cards/domain/entities/card.dart' as domain;

abstract class CardLocalDatasource {
  Future<List<domain.Card>> getCards();
  Future<domain.Card?> getCardById(int id);
  Future<void> insertCard(CardModel card);
  Future<void> insertCards(List<CardModel> cards);
  Future<void> clearCards();
  Future<int> getCardCount();
}

class CardLocalDatasourceImpl implements CardLocalDatasource {
  Database? _database;
  static bool _initialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!_initialized) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _initialized = true;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yugioh_cards.db');

    // Debug: Print actual database path
    debugPrint('📁 Card Database Path: $path');

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
            type TEXT,
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
      final type = maps[i]['type'] as String?;
      final isMonster = type?.toLowerCase().contains('monster') ?? false;

      return domain.Card(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: type,
        atk: isMonster
            ? (maps[i]['atk'] ?? 0)
            : 0, // Only show atk for monsters
        def: isMonster
            ? (maps[i]['def'] ?? 0)
            : 0, // Only show def for monsters
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
      type: maps.first['type'] as String?,
      atk:
          (maps.first['type'] as String?)?.toLowerCase().contains('monster') ??
              false
          ? (maps.first['atk'] ?? 0)
          : 0,
      def:
          (maps.first['type'] as String?)?.toLowerCase().contains('monster') ??
              false
          ? (maps.first['def'] ?? 0)
          : 0,
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
      'type': card.type, // Store type to identify monster cards
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
        'type': card.type, // Store type to identify monster cards
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

  @override
  Future<int> getCardCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cards');
    return result.first['count'] as int;
  }
}
