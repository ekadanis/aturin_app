import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/task/presentation/services/task_service.dart' as task;
import 'package:aturin_app/features/widget_aturin/services/home_service.dart';
import 'package:aturin_app/shared/core/services/api/profile/profile_service.dart';
import 'package:aturin_app/shared/core/services/api/auth/auth_service.dart';
import 'package:aturin_app/shared/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/features/schedule/presentation/services/aktivitas_service.dart';
import 'package:aturin_app/shared/core/providers/global_state_service.dart';
import 'package:aturin_app/shared/core/services/connectivity/connectivity_service.dart';
import 'package:aturin_app/shared/core/services/api/task/task_api_service.dart';

/// Registry untuk mengelola semua service yang diperlukan aplikasi
/// Memberikan akses yang mudah ke semua service dari context
class ProviderRegistry {
  static const String _tag = 'ProviderRegistry';
  
  /// Mendapatkan GlobalStateService dari context
  static GlobalStateService getGlobalStateService(BuildContext context) {
    try {
      return Provider.of<GlobalStateService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan ConnectivityService dari context
  static ConnectivityService getConnectivityService(BuildContext context) {
    try {
      return Provider.of<ConnectivityService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan AuthService dari context
  static AuthService getAuthService(BuildContext context) {
    try {
      return Provider.of<AuthService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan ProfileService dari context
  static ProfileService getProfileService(BuildContext context) {
    try {
      return Provider.of<ProfileService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan TaskService dari context
  static task.TaskService getTaskService(BuildContext context) {
    try {
      return Provider.of<task.TaskService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan TaskApiService dari context
  static TaskApiService getTaskApiService(BuildContext context) {
    try {
      return Provider.of<TaskApiService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan ActivityApiService dari context
  static ActivityApiService getActivityApiService(BuildContext context) {
    try {
      return Provider.of<ActivityApiService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan AktivitasService dari context
  static AktivitasService getAktivitasService(BuildContext context) {
    try {
      return Provider.of<AktivitasService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan HomeService dari context
  static HomeService getHomeService(BuildContext context) {
    try {
      return Provider.of<HomeService>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan service dengan listen = true
  static T watchService<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: true);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Mendapatkan service dengan listen = false
  static T readService<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Memeriksa apakah service tersedia di context
  static bool hasService<T>(BuildContext context) {
    try {
      Provider.of<T>(context, listen: false);
      return true;
    } catch (e) {
      return false;
    }
  }
}
