import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aturin_app/core/services/cache/cache_service.dart';

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
    debugPrint('🗄️ Cache: Data profil telah ditandai berubah, membersihkan cache...');
    _clearRelatedCaches();
    
    // Force data refresh from server on next fetch
    notifyListeners(); 
  }
  
  // Clear all related caches when data changes
  Future<void> _clearRelatedCaches() async {
    await _cacheService.removeData(_profileCacheKey);
    await _cacheService.removeData(_globalAlarmSettingCacheKey);
    
    debugPrint('🗄️ Cache: Semua cache terkait profil telah dibersihkan');
  }

  Future<User?> me({bool forceRefresh = false}) async {
    // Check if cache is valid and data hasn't changed
    if (!forceRefresh && !_dataChanged && await _cacheService.isCacheValid(_profileCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_profileCacheKey);
        if (cachedData != null) {
          final user = User.fromJson(cachedData);
          _currentUser = user;
          _dataChanged = false;
          debugPrint('🗄️ Cache: Menggunakan data profil dari cache');
          return user;
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error menggunakan cache untuk profil: $e');
      }
    }

    debugPrint('🗄️ Cache: Mengambil data profil dari server (forceRefresh=$forceRefresh)');
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'token',
      ); // Ambil token yang disimpan saat login

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

      debugPrint('Profile response status: ${response.statusCode}');
      debugPrint('Profile response body: ${response.body}');

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
          slug: userData['slug'] ??  '',
          createdAt:
              userData['created_at'] != null
                  ? DateTime.tryParse(userData['created_at'])
                  : null,
          updatedAt:
              userData['updated_at'] != null
                  ? DateTime.tryParse(userData['updated_at'])
                  : null,
        );

        // Save to cache
        await _cacheService.saveData(
          key: _profileCacheKey,
          data: user.toJson(),
          maxAge: _cacheValidityDuration,
        );
        
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
      final token = prefs.getString(
        'token',
      ); // Ambil token yang disimpan saat login

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

      debugPrint('Profile response status: ${response.statusCode}');
      debugPrint('Profile response body: ${response.body}');

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
          slug: userData['slug'] ??  '',
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
  }  Future<User?> getBannerProfile() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'token',
      ); // Ambil token yang disimpan saat login

      debugPrint('getBannerProfile: Checking token...');
      if (token == null) {
        debugPrint('getBannerProfile: Token tidak ditemukan.');
        _setError("Token tidak ditemukan.");
        _setLoading(false);
        return null;
      }

      debugPrint('getBannerProfile: Token found, making API call...');
      final response = await http.get(
        Uri.parse('$baseUrl/profile/banner'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('getBannerProfile response status: ${response.statusCode}');
      debugPrint('getBannerProfile response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null ||
            responseData['data'] == null ||
            responseData['data']['user'] == null) {
          debugPrint('getBannerProfile: Data profil tidak valid dari server');
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
          slug: userData['slug'] ??  '',
          createdAt: null,
          updatedAt: null,
        );

        debugPrint('getBannerProfile: User berhasil dibuat: ${user.name}');
        _currentUser = user;
        notifyListeners();
        return user;
      } else {
        debugPrint('getBannerProfile: Error status ${response.statusCode}');
        _setError("Gagal mengambil profil (Status: ${response.statusCode})");
        return null;
      }
    } catch (e) {
      debugPrint('getBannerProfile: Exception caught: $e');
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

      debugPrint('Global alarm status response status: ${response.statusCode}');
      debugPrint('Global alarm status response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null || responseData['data'] == null) {
          _setError('Data status alarm global tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final isEnabled = responseData['data']['is_global_alarm_enabled'] as bool;
        _isGlobalAlarmEnabled = isEnabled;
        notifyListeners();
        return isEnabled;
      } else {
        _setError("Gagal mengambil status alarm global (Status: ${response.statusCode})");
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

      debugPrint('Switch global alarm response status: ${response.statusCode}');
      debugPrint('Switch global alarm response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData == null || responseData['data'] == null) {
          _setError('Data status alarm global tidak valid dari server');
          _setLoading(false);
          return null;
        }

        final isEnabled = responseData['data']['is_global_alarm_enabled'] as bool;
        _isGlobalAlarmEnabled = isEnabled;
        notifyListeners();
        return isEnabled;
      } else {
        _setError("Gagal mengubah status alarm global (Status: ${response.statusCode})");
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
