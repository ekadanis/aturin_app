// lib/features/profile/database/profile_database.dart
import 'package:aturin_app/core/database/database_helper.dart';
import 'package:aturin_app/features/profile/models/user.dart';

class ProfileDatabase {
  /// Ambil user berdasarkan email
  Future<User?> getUserByEmail(String email) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  /// Ambil user berdasarkan ID
  Future<User?> getUserById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  /// Update hanya username
  Future<int> updateUsername(int userId, String newUsername) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Update hanya avatar
  Future<int> updateAvatar(int userId, String newAvatar) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'users',
      {'avatar': newAvatar},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Update seluruh data user
  Future<int> updateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
