import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/database/profile_database.dart';
import 'package:aturin_app/core/database/seeders/profile_seeder.dart';
import 'package:flutter/material.dart';

class ProfileService {
  final ProfileDatabase _profileDatabase = ProfileDatabase();

  Future<User?> getUser() async {
    // Coba ambil user dengan ID=1 (user default)
    User? user = await _profileDatabase.getUserById(1);
    debugPrint("User with ID=1: $user"); // Debug log
    
    // Jika tidak ditemukan, coba ambil berdasarkan email default
    if (user == null) {
      user = await _profileDatabase.getUserByEmail(ProfileSeeder.defaultEmail);
      debugPrint("User with email=${ProfileSeeder.defaultEmail}: $user"); // Debug log
    }
    
    if (user == null) {
      debugPrint("WARNING: No user found! Trying to create default user...");
      try {
        // Coba buat user default sebagai fallback
        await _createDefaultUser();
        user = await _profileDatabase.getUserById(1);
        debugPrint("Created default user: $user");
      } catch (e) {
        debugPrint("Error creating default user: $e");
      }
    }
    
    return user;
  }

  // Metode untuk membuat user default jika tidak ada
  Future<int> _createDefaultUser() async {
    final user = User(
      username: ProfileSeeder.defaultUsername, 
      email: ProfileSeeder.defaultEmail, 
      avatar: ProfileSeeder.defaultAvatar
    );
    
    return await _profileDatabase.insertUser(user.toMap());
  }

  Future<User?> getUserById(int id) async {
    return await _profileDatabase.getUserById(id);
  }


  Future<int> updateUser(User user) async {
    return await _profileDatabase.updateUser(user);
  }


  Future<void> changeUsername(int userId, String newUsername) async {
    final user = await getUserById(userId);
    if (user != null && user.username != newUsername) {
      await _profileDatabase.updateUsername(userId, newUsername);
    }
  }

  Future<void> changeAvatar(int userId, String newAvatar) async {
    final user = await getUserById(userId);
    if (user != null && user.avatar != newAvatar) {
      await _profileDatabase.updateAvatar(userId, newAvatar);
    }
  }
}
