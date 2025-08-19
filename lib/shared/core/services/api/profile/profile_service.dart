import 'dart:convert';
import 'package:aturin_app/shared/core/services/cache/cache_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';

  // Cache keys
  static const String _profileCacheKey = 'user_profile';
  static const String _globalAlarmSettingCacheKey = 'global_alarm_setting';
  static const Duration _cacheValidityDuration = Duration(minutes: 30);

  // Cache service instance
  final CacheService _cacheService = CacheService();

  // Flag to track if data has changed
  bool _dataChanged = false;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  bool? _isGlobalAlarmEnabled;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool? get isGlobalAlarmEnabled => _isGlobalAlarmEnabled;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Mark data as changed (called after update operations)
  void _markDataChanged() {
    _dataChanged = true;
    _clearRelatedCaches();

    // Force data refresh from server on next fetch
    notifyListeners();
  }

  // Clear all related caches when data changes
  Future<void> _clearRelatedCaches() async {
    await _cacheService.removeData(_profileCacheKey);
    await _cacheService.removeData(_globalAlarmSettingCacheKey);
  }

  // Public method to reset all profile data (untuk logout)
  // Public method to reset ALL app data (untuk logout)
  // Public method to reset ALL app data (untuk logout)
  // Public method to reset ALL app data (untuk logout)
  Future<void> clearAllAppCache() async {
    // Reset internal state
    _currentUser = null;
    _isGlobalAlarmEnabled = null;
    _dataChanged = true;

    // Daftar semua cache keys yang ingin dibersihkan dari CacheManager
    final cacheKeysToRemove = [
      // Profile related
      'user_profile',
      'global_alarm_setting',
      'profile_cache',
      'profile_banner_cache',

      // Task related
      'tasks_cache',
      'completed_tasks_cache',
      'uncompleted_tasks_cache',
      'overdue_tasks_cache',
      'all_tasks_cache',

      // Activity related
      'activities_cache',
      'today_activities_cache',
      'activity_categories_cache',

      // Home widget related
      'widget_data_cache',
      'home_widget_cache',

      // Other app caches
      'app_settings_cache',
      'notification_cache',
      'theme_cache',
    ];

    // Clear individual cache keys dari CacheManager
    try {
      await _cacheService.removeMultipleData(cacheKeysToRemove);
    } catch (e) {}

    // Clear semua cache di CacheManager
    try {
      await _cacheService.clearAll();
    } catch (e) {}

    // Untuk SharedPreferences, hanya hapus cache-related, bukan auth data
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemoveFromPrefs = [
        'global_alarm_enabled', // Setting alarm disimpan di SharedPreferences
      ];

      for (String key in keysToRemoveFromPrefs) {
        if (await prefs.containsKey(key)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {}

    notifyListeners();
  }

  Future<User?> me({bool forceRefresh = false}) async {
    // Jika forceRefresh=true, langsung ambil dari server tanpa cek cache
    if (!forceRefresh &&
        !_dataChanged &&
        await _cacheService.isCacheValid(_profileCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_profileCacheKey);
        if (cachedData != null) {
          final user = User.fromJson(cachedData);
          _currentUser = user;
          _dataChanged = false;
          return user;
        }
      } catch (e) {}
    }

    // Ambil data fresh dari server
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _setError("Token tidak ditemukan.");
        _setLoading(false);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/me'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null || responseData['data'] == null) {
          _setError('Data profil tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final userData = responseData['data'];

        final user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          avatar: userData['avatar'] ?? 'assets/avatars/profile1.jpg',
          slug: userData['slug'] ?? '',
          createdAt:
              userData['created_at'] != null
                  ? DateTime.tryParse(userData['created_at'])
                  : null,
          updatedAt:
              userData['updated_at'] != null
                  ? DateTime.tryParse(userData['updated_at'])
                  : null,
        );

        // Save to cache hanya jika bukan forceRefresh
        if (!forceRefresh) {
          await _cacheService.saveData(
            key: _profileCacheKey,
            data: user.toJson(),
            maxAge: _cacheValidityDuration,
          );
        }

        _currentUser = user;
        _dataChanged = false;
        notifyListeners();
        return user;
      } else {
        _setError("Gagal mengambil profil (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      _setError("Terjadi kesalahan: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> editProfile(String name, String avatar) async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _setError("Token tidak ditemukan.");
        _setLoading(false);
        return null;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/profile/edit'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'avatar': avatar}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null || responseData['data'] == null) {
          _setError('Data profil tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final userData = responseData['data'];

        final user = User(
          id: 0, // jika id tidak dikirim oleh endpoint ini, set default
          name: userData['name'],
          email: '', // atau gunakan default / kosong jika tidak tersedia
          avatar: userData['avatar'] ?? 'assets/avatars/profile1.jpg',
          slug: userData['slug'] ?? '',
          createdAt: DateTime.tryParse(userData['created_at'] ?? ''),
          updatedAt: DateTime.tryParse(userData['updated_at'] ?? ''),
        );

        _currentUser = user;
        _markDataChanged(); // Mark data as changed after update
        notifyListeners();
        return user;
      } else {
        _setError("Gagal mengambil profil (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      _setError("Terjadi kesalahan: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> getBannerProfile() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _setError("Token tidak ditemukan.");
        _setLoading(false);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/banner'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null ||
            responseData['data'] == null ||
            responseData['data']['user'] == null) {
          _setError('Data profil tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final data = responseData['data'];
        final userData = data['user'];

        final user = User(
          id: userData['id'] ?? 0,
          name: userData['name'],
          email: userData['email'] ?? '',
          avatar: userData['avatar'] ?? 'assets/avatars/profile1.jpg',
          slug: userData['slug'] ?? '',
          createdAt: null,
          updatedAt: null,
        );

        _currentUser = user;
        notifyListeners();
        return user;
      } else {
        _setError("Gagal mengambil profil (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      _setError("Terjadi kesalahan: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool?> getGlobalAlarmStatus() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _setError("Token tidak ditemukan.");
        _setLoading(false);
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/alarmGlobal'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null || responseData['data'] == null) {
          _setError('Data status alarm global tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final isEnabled =
            responseData['data']['is_global_alarm_enabled'] as bool;
        _isGlobalAlarmEnabled = isEnabled;
        notifyListeners();
        return isEnabled;
      } else {
        _setError(
          "Gagal mengambil status alarm global (Status: ${response.statusCode})",
        );
        return null;
      }
    } catch (e) {
      _setError("Terjadi kesalahan: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool?> switchGlobalAlarmStatus() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _setError("Token tidak ditemukan.");
        _setLoading(false);
        return null;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/profile/alarmGlobal'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null || responseData['data'] == null) {
          _setError('Data status alarm global tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final isEnabled =
            responseData['data']['is_global_alarm_enabled'] as bool;
        _isGlobalAlarmEnabled = isEnabled;
        notifyListeners();
        return isEnabled;
      } else {
        _setError(
          "Gagal mengubah status alarm global (Status: ${response.statusCode})",
        );
        return null;
      }
    } catch (e) {
      _setError("Terjadi kesalahan: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
