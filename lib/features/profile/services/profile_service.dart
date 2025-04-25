import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/database/profile_database.dart';
import 'package:aturin_app/core/database/seeders/profile_seeder.dart';

class ProfileService {
  final ProfileDatabase _profileDatabase = ProfileDatabase();

  Future<User?> getUser() async {
    return await _profileDatabase.getUserByEmail(ProfileSeeder.defaultEmail);
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
