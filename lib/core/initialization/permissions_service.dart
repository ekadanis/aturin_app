import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class PermissionsService {
  /// Request all permissions needed for the application to function properly
  static Future<void> requestAllPermissions() async {
    // Request notification permission first
    final notificationStatus = await Permission.notification.request();
    if (notificationStatus.isDenied) {
      debugPrint('Notification permission ditolak');
    }
    
    if (Platform.isAndroid) {

      // Request storage permissions
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isDenied) {
        debugPrint('Storage permission ditolak');
      }
      
      // Pada Android 13+ perlu izin eksplisit untuk notifikasi
      try {
        // Request the permissions needed for Android 13+
        final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
        if (exactAlarmStatus.isDenied) {
          debugPrint('scheduleExactAlarm permission ditolak');
        }
        
        final notificationPolicyStatus = await Permission.accessNotificationPolicy.request();
        if (notificationPolicyStatus.isDenied) {
          debugPrint('accessNotificationPolicy permission ditolak');
        }
      } catch (e) {
        debugPrint('Error saat memeriksa atau meminta izin Android: $e');
      }
    }
  }
}