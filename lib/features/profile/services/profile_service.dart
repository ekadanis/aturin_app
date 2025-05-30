import 'package:aturin_app/features/profile/models/user.dart';
// import 'package:aturin_app/features/profile/database/profile_database.dart'; // SQLite disabled
// import 'package:aturin_app/core/database/seeders/profile_seeder.dart'; // SQLite disabled
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  // final ProfileDatabase _profileDatabase = ProfileDatabase(); // SQLite disabled
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final userName = prefs.getString('userName');
      final userEmail = prefs.getString('userEmail');
      
      if (userId != null && userName != null && userEmail != null) {
        final user = User(
          id: userId,
          name: userName,
          email: userEmail,
          avatar: 'assets/avatars/profile1.jpg', // Default avatar
          slug: userName.toLowerCase().replaceAll(' ', '-'),
        );
        
        _currentUser = user;
        notifyListeners();
        return user;
      }
      
      debugPrint("No user data found in SharedPreferences");
      return null;
    } catch (e) {
      debugPrint("Error getting user from SharedPreferences: $e");
      return null;
    }
  }  // Method untuk update username (disabled - untuk online app)
  Future<void> changeUsername(int userId, String newName) async {
    try {
      debugPrint("changeUsername disabled - online mode");
      // TODO: Implement API call to update username
      // For now, update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newName);
      
      // Update current user
      if (_currentUser != null && _currentUser!.id == userId) {
        _currentUser = User(
          id: _currentUser!.id,
          name: newName,
          email: _currentUser!.email,
          avatar: _currentUser!.avatar,
          slug: newName.toLowerCase().replaceAll(' ', '-'),
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error changing username: $e");
    }
  }

  // Method untuk update avatar (disabled - untuk online app)
  Future<void> changeAvatar(int userId, String newAvatar) async {
    try {
      debugPrint("changeAvatar disabled - online mode");
      // TODO: Implement API call to update avatar
      // For now, update current user locally
      if (_currentUser != null && _currentUser!.id == userId) {
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          avatar: newAvatar,
          slug: _currentUser!.slug,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error changing avatar: $e");
    }
  }
}
