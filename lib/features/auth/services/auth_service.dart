import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';

class AuthService extends ChangeNotifier {
  // Use 10.0.2.2 for Android emulator to access host machine
  static const String baseUrl = 'http://127.0.0.1:8000';
  final ProfileService _profileService = ProfileService();

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

      // Generate slug from name
      String slug = _generateSlug(name);
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'http://localhost:3000',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'slug': slug,
        }),
      );

      debugPrint('Registration response status: ${response.statusCode}');
      debugPrint('Registration response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Create user object from response
        final user = User(
          id: data['user']['id'],
          name: data['user']['name'],
          email: data['user']['email'],
          avatar: data['user']['avatar'] ?? '/assets/avatars/profile1.jpg',
          slug: data['user']['slug'],
          createdAt:
              data['user']['created_at'] != null
                  ? DateTime.tryParse(data['user']['created_at'])
                  : null,
          updatedAt:
              data['user']['updated_at'] != null
                  ? DateTime.tryParse(data['user']['updated_at'])
                  : null,
        );

        _setLoading(false);
        return AuthResult.success(
          user: user,
          token: data['token'],
          message: data['message'] ?? 'Pendaftaran berhasil!',
        );
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Pendaftaran gagal';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'http://localhost:3000',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Create user object from response
        final user = User(
          id: data['user']['id'],
          name: data['user']['name'],
          email: data['user']['email'],
          avatar: data['user']['avatar'] ?? '/assets/avatars/profile1.jpg',
          slug: data['user']['slug'],
          createdAt:
              data['user']['created_at'] != null
                  ? DateTime.tryParse(data['user']['created_at'])
                  : null,
          updatedAt:
              data['user']['updated_at'] != null
                  ? DateTime.tryParse(data['user']['updated_at'])
                  : null,
        );

        _setLoading(false);
        return AuthResult.success(
          user: user,
          token: data['token'],
          message: data['message'] ?? 'Login berhasil!',
        );
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Login gagal';

        _setError(errorMessage);
        _setLoading(false);
        return AuthResult.failure(errorMessage);
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
