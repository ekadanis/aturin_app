// Test script untuk memverifikasi koneksi HTTP ke Laravel backend
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing HTTP connection to Laravel backend...');
  
  const String baseUrl = 'http://127.0.0.1:8000/api';
  
  try {
    // Test endpoint register
    print('\n1. Testing register endpoint...');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'Password123',
        'password_confirmation': 'Password123',
        'slug': 'test-user',
      }),
    );
    
    print('Register Response Status: ${registerResponse.statusCode}');
    print('Register Response Body: ${registerResponse.body}');
    
    // Test endpoint login jika registrasi berhasil
    if (registerResponse.statusCode == 201 || registerResponse.statusCode == 200) {
      print('\n2. Testing login endpoint...');
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': 'test@example.com',
          'password': 'password123',
        }),
      );
      
      print('Login Response Status: ${loginResponse.statusCode}');
      print('Login Response Body: ${loginResponse.body}');
    }
    
  } catch (e) {
    print('Error during HTTP test: $e');
    
    if (e.toString().contains('SocketException') || 
        e.toString().contains('Connection refused')) {
      print('\n❌ Cannot connect to Laravel server.');
      print('Please make sure:');
      print('1. Laravel server is running at http://127.0.0.1:8000');
      print('2. Run: php artisan serve');
      print('3. Check if the API routes are properly defined');
    } else if (e.toString().contains('TimeoutException')) {
      print('\n❌ Connection timeout. Server might be slow or unreachable.');
    } else {
      print('\n❌ Unexpected error: $e');
    }
  }
}
