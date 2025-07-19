import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Normalize email to lowercase and trim whitespace
      final normalizedEmail = email.trim().toLowerCase();

      // Validate email format
      if (!_isValidEmail(normalizedEmail)) {
        _setError('Format email tidak valid');
        _setLoading(false);
        return AuthResult.failure('Format email tidak valid');
      }

      // Generate slug from name
      String slug = _generateSlug(name);
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          //'Origin': 'http://localhost:3000',
        },
        body: jsonEncode({
          'name': name,
          'email': normalizedEmail, // Use normalized email
          'password': password,
          'password_confirmation': password,
          'slug': slug,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint('DEBUG: Parsed data: $data');
        debugPrint('DEBUG: data is null? ${data == null}');
        debugPrint(
          'DEBUG: data["data"] exists? ${data != null ? data.containsKey("data") : "data is null"}',
        );
        debugPrint(
          'DEBUG: data["data"]["user"] exists? ${data != null && data["data"] != null ? data["data"].containsKey("user") : "data or data[\"data\"] is null"}',
        );

        // Validate response structure - check for both possible structures
        Map<String, dynamic>? userData;

        if (data != null &&
            data['data'] != null &&
            data['data']['user'] != null) {
          // New API format: data.data.user
          debugPrint('DEBUG: Using new API format (data.data.user)');
          userData = data['data']['user'] as Map<String, dynamic>;
          debugPrint('DEBUG: userData: $userData');
        } else if (data != null && data['user'] != null) {
          // Old API format: data.user
          debugPrint('DEBUG: Using old API format (data.user)');
          userData = data['user'] as Map<String, dynamic>;
          debugPrint('DEBUG: userData: $userData');
        } else {
          debugPrint('DEBUG: Neither format found! data structure:');
          debugPrint('DEBUG: data keys: ${data?.keys.toList()}');
          if (data?['data'] != null) {
            debugPrint(
              'DEBUG: data["data"] keys: ${data["data"]?.keys?.toList()}',
            );
          }
          _setError('Response data tidak valid');
          _setLoading(false);
          return AuthResult.failure('Data registrasi tidak valid dari server');
        }

        // Ensure required fields exist
        debugPrint('DEBUG: Checking required fields...');
        debugPrint('DEBUG: userData["id"]: ${userData['id']}');
        debugPrint('DEBUG: userData["name"]: ${userData['name']}');
        debugPrint('DEBUG: userData["email"]: ${userData['email']}');

        if (userData['id'] == null ||
            userData['name'] == null ||
            userData['email'] == null) {
          debugPrint('DEBUG: Required fields missing!');
          _setError('Data user tidak lengkap');
          _setLoading(false);
          return AuthResult.failure('Data user tidak lengkap dari server');
        }

        debugPrint(
          'DEBUG: All required fields present, creating User object...',
        );

        // Create user object from response
        final user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          avatar: userData['avatar'] ?? '/assets/avatars/profile1.jpg',
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

        debugPrint(
          'DEBUG: User object created successfully: ${user.toString()}',
        );
        debugPrint('DEBUG: Token from response: ${data['token']}');
        debugPrint('DEBUG: Message from response: ${data['message']}');

        _setLoading(false);
        return AuthResult.success(
          user: user,
          token: data['token'],
          message: data['message'] ?? 'Pendaftaran berhasil!',
        );
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Pendaftaran gagal';

          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData != null && errorData['errors'] != null) {
            // Handle validation errors
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add(value.toString());
              }
            });
            errorMessage = errorMessages.join('\n');

            // Add helpful message for password validation
            if (errorMessage.contains('password')) {
              errorMessage +=
                  '\n\nCatatan: Password harus mengandung huruf besar, huruf kecil, angka, dan karakter khusus.';
            }
          }

          _setError(errorMessage);
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        } catch (e) {
          // If we can't parse the error response, use a generic message
          debugPrint('Error parsing error response: $e');
          String errorMessage =
              'Pendaftaran gagal (Status: ${response.statusCode})';
          _setError(errorMessage);
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        }
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan jaringan';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Pastikan Laravel server berjalan di $baseUrl';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Koneksi timeout. Coba lagi.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      }

      debugPrint('Registration error: $e');
      _setError(errorMessage);
      _setLoading(false);
      return AuthResult.failure(errorMessage);
    }
  }

  /// Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Normalize email to lowercase and trim whitespace
      final normalizedEmail = email.trim().toLowerCase();

      // Validate email format
      if (!_isValidEmail(normalizedEmail)) {
        _setError('Format email tidak valid');
        _setLoading(false);
        return AuthResult.failure('Format email tidak valid');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Origin': 'http://localhost:3000',
        },
        body: jsonEncode({
          'email': normalizedEmail, // Use normalized email
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Validate response structure - check for the correct nested structure
        if (responseData == null ||
            responseData['data'] == null ||
            responseData['data']['user'] == null) {
          _setError('Response data tidak valid');
          _setLoading(false);
          return AuthResult.failure('Data login tidak valid dari server');
        }

        final data = responseData['data'];
        final userData = data['user'];

        // Ensure required fields exist
        if (userData['id'] == null ||
            userData['name'] == null ||
            userData['email'] == null) {
          _setError('Data user tidak lengkap');
          _setLoading(false);
          return AuthResult.failure('Data user tidak lengkap dari server');
        }

        // Create user object from response
        final user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          avatar: userData['avatar'] ?? '/assets/avatars/profile1.jpg',
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

        _setLoading(false);
        return AuthResult.success(
          user: user,
          token: data['token'],
          message: data['message'] ?? 'Berhasil masuk!',
        );
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Login gagal';

          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }

          _setError(errorMessage);
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        } catch (e) {
          // If we can't parse the error response, use a generic message
          debugPrint('Error parsing login error response: $e');
          String errorMessage = 'Login gagal (Status: ${response.statusCode})';
          _setError(errorMessage);
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        }
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan jaringan';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage =
            'Tidak dapat terhubung ke server. Pastikan Laravel server berjalan di http://127.0.0.1:8000';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Koneksi timeout. Coba lagi.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      }

      debugPrint('Login error: $e');
      _setError(errorMessage);
      _setLoading(false);
      return AuthResult.failure(errorMessage);
    }
  }

  Future<AuthResult> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return AuthResult.failure('Token tidak ditemukan.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
   if (response.statusCode == 200) {
  // Hapus token dan status login
  await prefs.remove('token');
  await prefs.setBool('isLoggedIn', false);
  
  // NOTE: Cache lainnya akan dibersihkan oleh ProfileService.clearAllAppCache()
  
  return AuthResult.success(
    user: null,
    token: null,
    message: 'Logout berhasil',
  );
      } else {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Logout gagal';
        return AuthResult.failure(message);
      }
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan saat logout: $e');
    }
  }

  /// Generate slug from name
  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  /// Clear error message
  void clearError() {
    _setError(null);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validate password requirements
  static bool isPasswordValid(String password) {
    if (password.length < 8) return false;

    // Check for uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Check for lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Check for digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  /// Get password requirements message
  static String getPasswordRequirements() {
    return 'Password harus memiliki:\n'
        '• Minimal 8 karakter\n'
        '• Huruf besar (A-Z)\n'
        '• Huruf kecil (a-z)\n'
        '• Angka (0-9)\n'
        '• Karakter khusus (!@#\$%^&*(),.?":{}|<>)';
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? token;
  final String message;

  AuthResult.success({required this.user, this.token, required this.message})
    : isSuccess = true;

  AuthResult.failure(this.message)
    : isSuccess = false,
      user = null,
      token = null;
}
