import 'package:aturin_app/shared/core/infrastructure/routers/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../database/database_helper.dart';
import '../services/connectivity/connectivity_service.dart';
import 'app_initializer.dart';
/// Class untuk menangani bootstrap (inisialisasi awal) aplikasi
/// Memisahkan logic inisialisasi dari main.dart untuk struktur yang lebih clean
class AppBootstrap {
  static const String _tag = 'AppBootstrap';
  
  final AppRouter appRouter;
  final ConnectivityService connectivityService;
  final AppCreator? appCreator;
  
  // Constructor sederhana
  AppBootstrap({
    required this.appRouter,
    required this.connectivityService,
    this.appCreator,
  });
  
  /// Inisialisasi utama aplikasi - versi sangat ringan tanpa preloading
  /// Returns: Future<void>
  Future<void> initialize() async {
    try {
      debugPrint('$_tag: Starting ultra-lightweight app initialization...');
      
      // Initialize connectivity service first (highest priority)
      await connectivityService.initialize();
      debugPrint('$_tag: Connectivity service initialized successfully');
      
      // Add migration safety check
      await _handleMigrationSafety();
      
      // Initialize date formatting for Indonesian locale
      await initializeDateFormatting('id_ID', null);
      debugPrint('$_tag: Date formatting initialized for id_ID locale');
      
      // Inisialisasi sangat minimal (tanpa preloading sama sekali)
      final appInitializer = AppInitializer(appRouter);
      await appInitializer.initialize();
      
      // Setup alarm manager with app creator if provided
      if (appCreator != null) {
        appInitializer.alarmManager.setAppCreator(appCreator!);
      }
      
      debugPrint('$_tag: Ultra-lightweight app initialization completed successfully');
    } catch (e) {
      debugPrint('$_tag: Failed to initialize app: $e');
      throw Exception('App initialization failed: $e');
    }
  }
  
  /// Handle migration from SQLite to API version safely
  Future<void> _handleMigrationSafety() async {
    try {
      // Initialize database to ensure migration happens smoothly
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.database; // This will trigger migrations if needed
      debugPrint('$_tag: Database migration completed successfully');
    } catch (e) {
      debugPrint('$_tag: Migration safety check warning: $e');
      // Don't throw - let app continue with API-only mode
    }
  }
  
  /// Set device orientation to portrait only
  static Future<void> setPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('$_tag: Device orientation set to portrait only');
  }
  
  /// Preserve splash screen until initialization is complete
  static WidgetsBinding preserveSplashScreen() {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    debugPrint('$_tag: Splash screen preserved');
    return widgetsBinding;
  }
  
  /// Remove splash screen after initialization
  static void removeSplashScreen() {
    FlutterNativeSplash.remove();
    debugPrint('$_tag: Splash screen removed');
  }
}

// Type definition for app creator function
typedef AppCreator = Widget Function();
