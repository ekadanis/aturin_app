import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/database/profile_database.dart';
import 'package:aturin_app/core/database/seeders/profile_seeder.dart';
import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  final ProfileDatabase _profileDatabase = ProfileDatabase();
  User? _currentUser;

  User? get currentUser => _currentUser;

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
    
    _currentUser = user;
    notifyListeners();
    return user;
  }
  // Metode untuk membuat user default jika tidak ada
  Future<int> _createDefaultUser() async {
    final user = User(
      name: ProfileSeeder.defaultName, 
      email: ProfileSeeder.defaultEmail, 
      avatar: ProfileSeeder.defaultAvatar,
      slug: ProfileSeeder.defaultSlug,
    );
    
    return await _profileDatabase.insertUser(user.toMap());
  }

  Future<User?> getUserById(int id) async {
    final user = await _profileDatabase.getUserById(id);
    return user;
  }


  Future<int> updateUser(User user) async {
    final result = await _profileDatabase.updateUser(user);
    _currentUser = user;
    notifyListeners();
    return result;
  }

  Future<void> changeUsername(int userId, String newName) async {
    try {
      final user = await getUserById(userId);
      if (user != null && user.name != newName) {
        await _profileDatabase.updateUsername(userId, newName);
        // Dapatkan user yang sudah diupdate dari database
        final updatedUser = await getUserById(userId);
        if (updatedUser != null && _currentUser != null && _currentUser!.id == userId) {
          _currentUser = updatedUser;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error changing username: $e");
    }
  }

  Future<void> changeAvatar(int userId, String newAvatar) async {
    try {
      final user = await getUserById(userId);
      if (user != null && user.avatar != newAvatar) {
        await _profileDatabase.updateAvatar(userId, newAvatar);
        // Dapatkan user yang sudah diupdate dari database
        final updatedUser = await getUserById(userId);
        if (updatedUser != null && _currentUser != null && _currentUser!.id == userId) {
          _currentUser = updatedUser;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error changing avatar: $e");
    }
  }
}
