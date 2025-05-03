import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:aturin_app/features/alarm/ui/screens/alarm_ringing_screen.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:sizer/sizer.dart'; // Import sizer untuk inisialisasi

typedef AppCreator = Widget Function();

class AlarmManager {
  final AppRouter appRouter;
  AppCreator? _appCreator;

  AlarmManager(this.appRouter);

  /// Initialize the alarm package and set up the listener for alarm events
  Future<void> initialize() async {
    // Inisialisasi alarm package
    await Alarm.init();
    
    // Mendengarkan event ketika alarm berbunyi
    Alarm.ringStream.stream.listen(_handleAlarmRinging);

    debugPrint('Alarm manager initialized successfully');
  }
  
  /// Set the app creator function that will be used to restart the app after an alarm
  void setAppCreator(AppCreator appCreator) {
    _appCreator = appCreator;
  }

  /// Handle alarm ringing event by navigating to the alarm screen
  void _handleAlarmRinging(AlarmSettings alarmSettings) {
    debugPrint('Alarm berbunyi: ${alarmSettings.id}');
    
    // Cek apakah aplikasi sudah berjalan atau sedang di background
    final context = appRouter.navigatorKey.currentContext;
    
    // Jika context tersedia, gunakan AutoRouter untuk navigasi
    if (context != null) {
      // Navigasi dengan Auto Router jika aplikasi sudah berjalan
      appRouter.push(AlarmRingingRoute(alarmSettings: alarmSettings));
      debugPrint('Navigasi ke AlarmRingingScreen dengan AutoRouter');
    } else {
      // Jika aplikasi belum berjalan atau di background, gunakan tampilan overlay
      // yang akan kembali ke aplikasi normal setelah alarm dimatikan
      runApp(
        // Gunakan Sizer untuk memastikan dependensi diinisialisasi dengan benar
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                ),
              ),
              home: AlarmRingingScreen(
                alarmSettings: alarmSettings,
                // Memberikan callback untuk restart aplikasi normal setelah alarm dimatikan
                onDismiss: () {
                  // Restart aplikasi dengan aplikasi utama
                  if (_appCreator != null) {
                    runApp(_appCreator!());
                  } else {
                    debugPrint('Error: App creator not set in AlarmManager');
                  }
                },
              ),
            );
          }
        ),
      );
      debugPrint('Menampilkan AlarmRingingScreen sebagai aplikasi terpisah');
    }
  }
}