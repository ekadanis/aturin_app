import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:aturin_app/features/home/services/home_service.dart';
import 'package:aturin_app/features/home/providers/home_widget_provider.dart';
import 'package:aturin_app/core/services/api/profile/profile_service.dart';
import 'package:aturin_app/core/services/api/auth/auth_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/features/jadwal/services/aktivitas_service.dart';
import 'package:aturin_app/core/providers/global_state_service.dart';
import 'package:aturin_app/core/services/connectivity/connectivity_service.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:aturin_app/features/task/services/task_service.dart';
import 'package:aturin_app/features/task/services/task_utility_service.dart';
import 'package:aturin_app/core/services/cache/cache_service.dart';

/// Kelas untuk mengatur konfigurasi semua Provider dalam aplikasi
/// Digunakan untuk memisahkan Provider setup dari main.dart agar lebih terorganisir
class ProviderConfig {
  /// Mendapatkan daftar semua Provider yang diperlukan aplikasi
  /// 
  /// [connectivityService] - Instance ConnectivityService yang sudah diinisialisasi
  ///   /// Returns List<SingleChildWidget> - Daftar provider yang siap digunakan
  static List<SingleChildWidget> getProviders({
    required ConnectivityService connectivityService,
  }) {
    return [
      // Core Services
      ChangeNotifierProvider<ConnectivityService>.value(
        value: connectivityService,
      ),
      
      // Cache Service (Single instance)
      Provider<CacheService>(
        create: (_) => CacheService(),
      ),
      
      // Authentication & User Management
      ChangeNotifierProvider<AuthService>(
        create: (_) => AuthService(),
      ),
      ChangeNotifierProvider<ProfileService>(
        create: (_) => ProfileService(),
      ),
      
      // Task Management Services (Must be before GlobalStateService)
      ChangeNotifierProvider<TaskApiService>(
        create: (_) => TaskApiService(),
      ),
      Provider<AlarmApiService>(
        create: (_) => AlarmApiService(),
      ),
      Provider<TaskUtilityService>(
        create: (_) => TaskUtilityService(),
      ),
      ChangeNotifierProvider<TaskService>(
        create: (context) => TaskService(
          taskApiService: context.read<TaskApiService>(),
          alarmApiService: context.read<AlarmApiService>(),
          utilityService: context.read<TaskUtilityService>(),
        ),
      ),
      
      // Activity Management Services
      ChangeNotifierProvider<ActivityApiService>(
        create: (_) => ActivityApiService(),
      ),
      ChangeNotifierProvider<AktivitasService>(
        create: (_) => AktivitasService(),
      ),
      
      // Global State Management (Must be after TaskApiService)
      ChangeNotifierProvider<GlobalStateService>(
        create: (context) => GlobalStateService(
          taskApiService: context.read<TaskApiService>(),
        )..initialize(),
      ),
      
      // Home Services
      Provider<HomeService>(
        create: (_) => HomeService(),
      ),
      
      // Home Widget Provider
      ChangeNotifierProvider<HomeWidgetProvider>(
        create: (_) => HomeWidgetProvider()..initialize(),
      ),
    ];
  }
}
