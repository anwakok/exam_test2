import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:game/features/user/domain/entities/user.dart';

class FileUserService {
  static const String _usersDir = 'users_data';
  static const String _usersFile = 'users.json';
  static const String _currentUserFile = 'current_user.json';

  static Future<String> get _basePath async {
    final currentDir = Directory.current;
    final usersDir = Directory(path.join(currentDir.path, _usersDir));

    if (!await usersDir.exists()) {
      await usersDir.create(recursive: true);
    }

    return usersDir.path;
  }

  static Future<File> get _usersFileRef async {
    final basePath = await _basePath;
    return File(path.join(basePath, _usersFile));
  }

  static Future<File> get _currentUserFileRef async {
    final basePath = await _basePath;
    return File(path.join(basePath, _currentUserFile));
  }

  static Future<List<User>> getAllUsers() async {
    try {
      final file = await _usersFileRef;
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading users file: $e');
      return [];
    }
  }

  static Future<User?> getUserByUsername(String username) async {
    try {
      final users = await getAllUsers();
      try {
        return users.firstWhere((user) => user.username == username);
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error finding user: $e');
      return null;
    }
  }

  static Future<User> createUser({
    required String username,
    String? email,
    String? password,
  }) async {
    final existingUser = await getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('Username already exists');
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

  static Future<User> updateUser(User user) async {
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

  static Future<void> deleteUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((user) => user.id == userId);
    await _saveUsers(users);
  }

  static Future<User?> getCurrentUser() async {
    try {
      final file = await _currentUserFileRef;
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return null;
      }

      final json = jsonDecode(content);
      return User.fromJson(json);
    } catch (e) {
      debugPrint('Error reading current user file: $e');
      return null;
    }
  }

  static Future<void> setCurrentUser(User user) async {
    final file = await _currentUserFileRef;
    await file.writeAsString(jsonEncode(user.toJson()));
  }

  static Future<void> _saveUsers(List<User> users) async {
    final file = await _usersFileRef;
    final jsonList = users.map((user) => user.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  static Future<void> clearCurrentUser() async {
    try {
      final file = await _currentUserFileRef;
      if (await file.exists()) {
        await file.delete();
      }
      debugPrint('Current user cleared');
    } catch (e) {
      debugPrint('Error clearing current user: $e');
    }
  }

  static Future<void> clearAllUsers() async {
    try {
      final basePath = await _basePath;
      final usersFile = File(path.join(basePath, _usersFile));
      final currentUserFile = File(path.join(basePath, _currentUserFile));

      if (await usersFile.exists()) {
        await usersFile.delete();
      }

      if (await currentUserFile.exists()) {
        await currentUserFile.delete();
      }

      debugPrint('All user data cleared from files');
    } catch (e) {
      debugPrint('Error clearing user files: $e');
    }
  }

  static Future<void> backupUsers() async {
    try {
      final basePath = await _basePath;
      final usersFile = await _usersFileRef;

      if (await usersFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFile = File(
          path.join(basePath, 'users_backup_$timestamp.json'),
        );
        await usersFile.copy(backupFile.path);
        debugPrint('Users backed up to: ${backupFile.path}');
      }
    } catch (e) {
      debugPrint('Error backing up users: $e');
    }
  }
}
