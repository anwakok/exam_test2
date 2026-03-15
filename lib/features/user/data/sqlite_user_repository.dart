import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import '../domain/entities/user.dart';

class SQLiteUserRepository {
  final _uuid = const Uuid();

  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((map) => _mapToUser(map)).toList();
  }

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  // Create user
  Future<User> createUser({
    required String username,
    String? email,
    String? password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('users', {
      'id': id,
      'username': username,
      'email': email,
      'password': password ?? '',
      'total_games': 0,
      'best_time': 999999,
      'best_moves': 999999,
      'created_at': now,
    });

    return User(
      id: id,
      username: username,
      email: email,
      password: password ?? '',
      totalGames: 0,
      bestTime: 999999,
      bestMoves: 999999,
      createdAt: DateTime.parse(now),
    );
  }

  // Update user
  Future<User> updateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'total_games': user.totalGames,
        'best_time': user.bestTime,
        'best_moves': user.bestMoves,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final db = await DatabaseHelper.instance.database;
    final currentUserMaps = await db.query('current_user', limit: 1);

    if (currentUserMaps.isEmpty) {
      return null;
    }

    final userId = currentUserMaps.first['user_id'] as String?;
    if (userId == null) return null;

    return await getUserById(userId);
  }

  // Set current user
  Future<void> setCurrentUser(String userId) async {
    final db = await DatabaseHelper.instance.database;

    // Clear existing
    await db.delete('current_user');

    // Insert new
    await db.insert('current_user', {'id': 1, 'user_id': userId});
  }

  // Clear current user
  Future<void> clearCurrentUser() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('current_user');
  }

  // Map database row to User entity
  User _mapToUser(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String?,
      password: map['password'] as String?,
      totalGames: map['total_games'] as int? ?? 0,
      bestTime: map['best_time'] as int? ?? 999999,
      bestMoves: map['best_moves'] as int? ?? 999999,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
