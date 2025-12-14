// lib/auth/local_auth_service.dart
import 'package:shared_preferences/shared_preferences.dart'; // Keep for simple flags if needed, or remove if fully migrating
import '../database/sqlite_service.dart';
import '../database/models/user_model.dart';

/// Offline auth using SQLite.
class LocalAuthService {
  final SQLiteService _db = SQLiteService();
  static const _kLoggedInKey = 'vetra_logged_in_v1';
  static const _kUsernameKey = 'vetra_username_v1';

  // We still use SharedPreferences for the simple "isLoggedIn" boolean flag
  // as it's efficient for session state, but USER DATA is now in SQLite.
  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  /// Register a new user. Returns true if successful, false if username exists.
  Future<bool> register(String username, String password) async {
    final existingUser = await _db.getUser(username);
    if (existingUser != null) {
      return false; // User already exists
    }

    await _db.createUser(UserModel(username: username, password: password));
    return true;
  }

  /// Login with username and password. Returns true if credentials match.
  Future<bool> login(String username, String password) async {
    final user = await _db.getUser(username);
    
    if (user != null && user.password == password) {
      final p = await _prefs;
      await p.setBool(_kLoggedInKey, true);
      await p.setString(_kUsernameKey, username);
      return true;
    }
    return false;
  }

  /// Check if user is already logged in
  Future<bool> get isLoggedIn async {
    final p = await _prefs;
    return p.getBool(_kLoggedInKey) ?? false;
  }

  /// Get current username if logged in
  Future<String?> getCurrentUser() async {
    final p = await _prefs;
    if (await isLoggedIn) {
       return p.getString(_kUsernameKey);
    }
    return null;
  }

  /// Logout the current user
  Future<void> logout() async {
    final p = await _prefs;
    await p.remove(_kLoggedInKey);
    await p.remove(_kUsernameKey);
  }

  // --- Debug/Admin Helpers ---

  Future<void> deleteUser(String username) async {
    // This requires implementing delete in SQLiteService, 
    // but for now we basically mock or ignore if not critical.
    final db = await _db.database;
    await db.delete('users', where: 'username = ?', whereArgs: [username]);
  }
}
