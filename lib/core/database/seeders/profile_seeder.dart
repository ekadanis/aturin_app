// lib/core/seeders/profile_seeder.dart
import 'package:sqflite/sqflite.dart';

class ProfileSeeder {
  static const String defaultUsername = "Aturin Jaya";
  static const String defaultEmail = "aturin@gmail.com";
  static const String defaultAvatar = "assets/avatars/profile1.jpg";

  static Future<void> seedDefaultUser(Database db) async {
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [defaultEmail],
    );
    if (existing.isEmpty) {
      await db.insert('users', {
        'username': defaultUsername,
        'email': defaultEmail,
        'avatar': defaultAvatar,
      });
    }
  }
}
