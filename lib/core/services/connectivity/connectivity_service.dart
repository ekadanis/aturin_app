import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;
  bool _isChecking = false;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      await _checkConnectivity();
    });
  }

  /// Check current connectivity status
  Future<bool> _checkConnectivity() async {
    try {
      _isChecking = true;
      notifyListeners();

      final connectivityResult = await _connectivity.checkConnectivity();
      debugPrint(
        'ConnectivityService: Network connectivity result: $connectivityResult',
      );

      // If no network connection, mark as disconnected
      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('ConnectivityService: No network connection detected');
        _isConnected = false;
        _isChecking = false;
        notifyListeners();
        return false;
      }

      // If we have network connection, verify with actual internet check
      debugPrint(
        'ConnectivityService: Network available, checking internet connection...',
      );
      final hasInternet = await _checkInternetConnection();
      debugPrint(
        'ConnectivityService: Internet connection result: $hasInternet',
      );
      _isConnected = hasInternet;
      _isChecking = false;
      notifyListeners();

      return hasInternet;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isConnected = false;
      _isChecking = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify actual internet connection by making a test request
  Future<bool> _checkInternetConnection() async {
    try {
      debugPrint('ConnectivityService: Testing internet connection...');
      // Try multiple reliable endpoints
      final testUrls = [
        'https://www.google.com',
        'https://www.cloudflare.com',
        'https://1.1.1.1',
      ];

      for (String url in testUrls) {
        try {
          debugPrint('ConnectivityService: Testing URL: $url');
          final response = await http
              .get(Uri.parse(url), headers: {'Connection': 'keep-alive'})
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            debugPrint(
              'ConnectivityService: Internet connection verified via $url',
            );
            return true;
          }
        } catch (e) {
          debugPrint('ConnectivityService: Failed to connect to $url: $e');
          // Continue to next URL
          continue;
        }
      }

      debugPrint('ConnectivityService: All internet connection tests failed');
      return false;
    } catch (e) {
      debugPrint('ConnectivityService: Internet connection test failed: $e');
      return false;
    }
  }

  /// Manual connectivity check (for refresh button)
  Future<bool> checkConnectivityManually() async {
    debugPrint('Manual connectivity check started');
    return await _checkConnectivity();
  }

  Future<bool> hasNetworkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking network connectivity: $e');
      return false;
    }
  }

  Future<String> getConnectivityType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else {
        return 'No Connection';
      }
    } catch (e) {
      debugPrint('Error getting connectivity type: $e');
      return 'Unknown';
    }
  }


  Future<bool> testServerConnection(String baseUrl) async {
    try {
      debugPrint('Testing server connection to: $baseUrl');

      // Test the actual API endpoint
      final response = await http
          .get(
            Uri.parse('$baseUrl/v1/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'Aturin-App',
            },
          )
          .timeout(const Duration(seconds: 10));

      // Accept various status codes that indicate server is reachable
      // 405 (Method Not Allowed) means server is responding but GET is not allowed
      // 400 (Bad Request) means server is responding but request format is wrong
      // 200 (OK) means server is responding properly
      debugPrint('Server response status: ${response.statusCode}');
      return response.statusCode == 200 ||
          response.statusCode == 405 ||
          response.statusCode == 400 ||
          response.statusCode ==
              422; // Unprocessable Entity (validation errors)
    } catch (e) {
      debugPrint('Server connection test failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
