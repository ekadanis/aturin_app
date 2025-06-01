import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<User?> me() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'userToken',
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
          slug: userData['slug'] ?? _generateSlug(userData['name']),
          createdAt:
              userData['created_at'] != null
                  ? DateTime.tryParse(userData['created_at'])
                  : null,
          updatedAt:
              userData['updated_at'] != null
                  ? DateTime.tryParse(userData['updated_at'])
                  : null,
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

  Future<User?> editProfile(String name, String avatar) async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'userToken',
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
          slug: userData['slug'] ?? _generateSlug(userData['name']),
          createdAt: DateTime.tryParse(userData['created_at'] ?? ''),
          updatedAt: DateTime.tryParse(userData['updated_at'] ?? ''),
          todayActivities: null,
          todayTasks: null,
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

  Future<User?> getBannerProfile() async {
    try {
      _setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'userToken',
      ); // Ambil token yang disimpan saat login

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

      debugPrint('Profile response status: ${response.statusCode}');
      debugPrint('Profile response body: ${response.body}');

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
          slug: userData['slug'] ?? _generateSlug(userData['name']),
          createdAt: null,
          updatedAt: null,
          todayActivities: data['today_activities'],
          todayTasks: data['today_tasks'],
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

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }
}
