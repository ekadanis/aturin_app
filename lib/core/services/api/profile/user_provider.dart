// import 'package:flutter/material.dart';
// import 'package:aturin_app/features/profile/models/user.dart';
// import 'package:aturin_app/core/services/api/profile/profile_service.dart';

// class UserProvider extends ChangeNotifier {
//   final ProfileService _profileService; // langsung buat instance

//   User? _user;
//   User? get user => _user;

//   bool _loading = false;
//   bool get loading => _loading;

//   UserProvider(this._profileService) {
//     fetchUser(); // langsung fetch
//   }

//   Future<void> fetchUser() async {
//     _loading = true;
//     notifyListeners();

//     try {
//       final user = await _profileService.me(); // gunakan instance internal
//       _user = user;
//     } finally {
//       _loading = false;
//       notifyListeners();
//     }
//   }

//   void clearUser() {
//     _user = null;
//     notifyListeners();
//   }
// }
