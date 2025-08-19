// lib/core/seeders/profile_seeder.dart
import 'package:sqflite/sqflite.dart';

class ProfileSeeder {
  static const String defaultName = "Aturin Jaya";
  static const String defaultEmail = "aturin@gmail.com";
  static const String defaultAvatar = "assets/avatars/profile1.jpg";
  static const String defaultSlug = "aturin-jaya";

  static Future<void> seedDefaultUser(Database db) async {
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [defaultEmail],
    );
    if (existing.isEmpty) {
      await db.insert('users', {
        'name': defaultName,
        'email': defaultEmail,
        'avatar': defaultAvatar,
        'slug': defaultSlug,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
