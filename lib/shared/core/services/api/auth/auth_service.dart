import 'dart:convert';
import 'package:aturin_app/features/profile/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user_model.dart';
import 'package:aturin_app/features/device/services/device_service.dart';
import 'package:aturin_app/features/device/services/app_lifecycle_service.dart';
import 'package:aturin_app/features/device/services/device_activity_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';

  bool _isLoading = false;
  String? _errorMessage;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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

        // Validate response structure - check for both possible structures
        Map<String, dynamic>? userData;

        if (data != null &&
            data['data'] != null &&
            data['data']['user'] != null) {
          // New API format: data.data.user
          userData = data['data']['user'] as Map<String, dynamic>;
        } else if (data != null && data['user'] != null) {
          // Old API format: data.user
          userData = data['user'] as Map<String, dynamic>;
        } else {
          _setError('Response data tidak valid');
          _setLoading(false);
          return AuthResult.failure('Data registrasi tidak valid dari server');
        }

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

      _setError(errorMessage);
      _setLoading(false);
      return AuthResult.failure(errorMessage);
    }
  }


  Future<AuthResult> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      // First sign out to ensure user can select account
      await _googleSignIn.signOut();

      // Sign in with Google to get user info
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return AuthResult.failure('Login Google dibatalkan');
      }

      // Get Google authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        _setLoading(false);
        return AuthResult.failure('Gagal mendapatkan token Google');
      }

      final originalName = googleUser.displayName ?? '';
      final truncatedName = originalName.length > 20 
          ? originalName.substring(0, 20).trim()
          : originalName;
      
      debugPrint('Google Sign-In: Original name: "$originalName", Truncated: "$truncatedName"');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/mobile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': googleUser.email,
          'name': truncatedName,
          'google_id': googleUser.id,
          'avatar': 'assets/avatars/profile1.jpg',
          'provider': 'google',
        }),
      );

      // Debug: Print status code dan response
      debugPrint('Google Login Response Status: ${response.statusCode}');
      debugPrint('Google Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Debug: Print response untuk troubleshooting
        debugPrint('Google Login Response: $responseData');

        if ((responseData['success'] == true || responseData['status'] == 'Berhasil') && responseData['data'] != null) {
          final data = responseData['data'];
          final userData = data['user'];
          final token = data['token'];
          final message = responseData['message'] ?? 'Login Google berhasil!';
          
          if (userData != null && token != null) {
            // Save token to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            
            // Debug: Print successful login info
            debugPrint('Google Login Success: User ID = ${userData['id']}, Email = ${userData['email']}');
            debugPrint('Google Login: Creating User object with data: $userData');

            // Create user object from response
            final user = User(
              id: userData['id'],
              name: userData['name'],
              email: userData['email'],
              avatar: 'assets/avatars/profile1.jpg',
              slug: userData['slug'] ?? _generateSlug(userData['name']),
              createdAt:
                  userData['created_at'] != null
                      ? DateTime.tryParse(userData['created_at'])
                      : null,
              updatedAt:
                  userData['updated_at'] != null
                      ? DateTime.tryParse(userData['updated_at'])
                      : null,
              googleId: userData['google_id'],
              provider: userData['provider'],
              is_global_enabled: userData['is_global_alarm_enabled'] ?? userData['is_global_enabled'] ?? true,
            );
            
            debugPrint('Google Login: User object created successfully: ${user.name} (${user.email})');


            _setLoading(false);
            return AuthResult.success(
              user: user,
              token: token,
              message: message,
            );
          }
        } else {
          // Handle error response
          final errorMessage = responseData['message'] ?? 'Login Google gagal - Response tidak valid';
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        }
        
        _setLoading(false);
        return AuthResult.failure(
          'Login Google gagal - Response tidak valid',
        );
      } else {
        // Debug: Print status code dan response body
        debugPrint('Server Error - Status: ${response.statusCode}');
        debugPrint('Server Error - Body: ${response.body}');
        
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = 'Login Google gagal';

          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }

          _setError(errorMessage);
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        } catch (e) {
          String errorMessage =
              'Login Google gagal (Status: ${response.statusCode}) - ${response.body}';
          _setError(errorMessage);
          _setLoading(false);
          return AuthResult.failure(errorMessage);
        }
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan pada Google Sign-In';

      // Debug: Print error untuk troubleshooting  
      debugPrint('Google Sign-In Error: $e');

      if (e.toString().contains('network_error')) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      } else if (e.toString().contains('sign_in_canceled')) {
        errorMessage = 'Login Google dibatalkan';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = 'Google Sign-In belum dikonfigurasi. Pastikan google-services.json sudah benar.';
      } else if (e.toString().contains('GoogleSignIn')) {
        errorMessage = 'Konfigurasi Google Sign-In bermasalah. Periksa setup OAuth.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      }

      _setError(errorMessage);
      _setLoading(false);
      return AuthResult.failure(errorMessage);
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect(); // Fully disconnect to clear account cache
      debugPrint('Google Sign-In: Signed out and disconnected successfully');
    } catch (e) {
      // Ignore Google sign out errors
      debugPrint('Google sign out error: $e');
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

        // Sign out from Google if user was signed in with Google
        await signOutGoogle();

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
