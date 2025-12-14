// lib/auth/local_auth_service.dart
import '../database/isar_service.dart';
import '../database/models/user_model.dart';

class LocalAuthService {
  /// Register a new user (username must be unique).
  /// Returns true if registration succeeded, false if user already exists.
  Future<bool> register(String username, String password) async {
    final isar = await IsarService.db;

    // get all users (small dataset - acceptable)
    final users = await isar.userModels.where().findAll();
    final exists = users.any((u) => u.username == username);
    if (exists) return false;

    final user = UserModel()
      ..username = username
      ..password = password;

    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });

    return true;
  }

  /// Login using username + password.
  /// Returns true if credentials match an existing user.
  Future<bool> login(String username, String password) async {
    final isar = await IsarService.db;

    final users = await isar.userModels.where().findAll();
    for (final u in users) {
      if (u.username == username && u.password == password) return true;
    }
    return false;
  }

  /// Debug: list all users
  Future<List<UserModel>> allUsers() async {
    final isar = await IsarService.db;
    return await isar.userModels.where().findAll();
  }
}

