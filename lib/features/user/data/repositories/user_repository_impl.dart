import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/features/user/domain/entities/user.dart';
import 'package:uuid/uuid.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Future<User?> getUserByUsername(String username);
  Future<User> createUser(String username, {String? email, String? password});
  Future<User> updateUser(User user);
  Future<void> deleteUser(String userId);
  Future<User?> getCurrentUser();
  Future<void> setCurrentUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  final SharedPreferences _prefs;
  final Uuid _uuid;

  UserRepositoryImpl(this._prefs, this._uuid);

  @override
  Future<List<User>> getAllUsers() async {
    final usersJson = _prefs.getStringList(_usersKey) ?? [];
    return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> createUser(
    String username, {
    String? email,
    String? password,
  }) async {
    final existingUser = await getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('Username already exists');
    }

    final newUser = User(
      id: _uuid.v4(),
      username: username,
      email: email,
      password: password,
      createdAt: DateTime.now(),
    );

    final users = await getAllUsers();
    users.add(newUser);

    await _saveUsers(users);
    await setCurrentUser(newUser);

    return newUser;
  }

  @override
  Future<User> updateUser(User user) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);

    if (index != -1) {
      users[index] = user;
      await _saveUsers(users);
      await setCurrentUser(user);
      return user;
    }

    throw Exception('User not found');
  }

  @override
  Future<void> deleteUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((user) => user.id == userId);
    await _saveUsers(users);
  }

  @override
  Future<User?> getCurrentUser() async {
    final currentUserJson = _prefs.getString(_currentUserKey);
    if (currentUserJson != null) {
      return User.fromJson(jsonDecode(currentUserJson));
    }
    return null;
  }

  @override
  Future<void> setCurrentUser(User user) async {
    await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<void> _saveUsers(List<User> users) async {
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await _prefs.setStringList(_usersKey, usersJson);
  }
}
