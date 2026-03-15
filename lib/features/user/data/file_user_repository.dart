import 'package:game/features/user/domain/entities/user.dart';
import 'package:game/features/user/data/file_user_service.dart';

class FileUserRepository {
  Future<List<User>> getAllUsers() async {
    return await FileUserService.getAllUsers();
  }

  Future<User?> getUserByUsername(String username) async {
    return await FileUserService.getUserByUsername(username);
  }

  Future<User> createUser(
    String username, {
    String? email,
    String? password,
  }) async {
    return await FileUserService.createUser(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<User> updateUser(User user) async {
    return await FileUserService.updateUser(user);
  }

  Future<void> deleteUser(String userId) async {
    await FileUserService.deleteUser(userId);
  }

  Future<User?> getCurrentUser() async {
    return await FileUserService.getCurrentUser();
  }

  Future<void> setCurrentUser(User user) async {
    await FileUserService.setCurrentUser(user);
  }

  Future<void> clearAllUsers() async {
    await FileUserService.clearAllUsers();
  }

  Future<void> backupUsers() async {
    await FileUserService.backupUsers();
  }
}
