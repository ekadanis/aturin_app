import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:aturin_app/features/alarm/services/alarm_service.dart';
import 'package:aturin_app/features/alarm/ui/screens/alarm_ring_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

// GlobalKey untuk navigasi dari luar context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Pastikan ini dipanggil sebelum mengakses Flutter services
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inisialisasi format tanggal untuk locale 'id_ID' (Indonesia)
    await initializeDateFormatting('id_ID', null);
    
    // Minta izin yang diperlukan untuk alarm
    await requestPermissions();
    
    // Inisialisasi alarm package
    await Alarm.init();
    
    // Mendengarkan event ketika alarm berbunyi
    Alarm.ringStream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings)
    );
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(const Aturin());
  } catch (e) {
    // Menangkap dan mencatat error yang terjadi selama inisialisasi
    debugPrint('Error selama inisialisasi aplikasi: $e');
    // Jalankan aplikasi dengan pesan error jika diperlukan, atau lakukan penanganan lain
    runApp(const ErrorApp());
  }
}

// Widget untuk menampilkan jika ada error fatal
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 50, color: Colors.red),
              SizedBox(height: 16),
              Text('Terjadi kesalahan saat memulai aplikasi',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Silakan restart aplikasi atau hubungi dukungan',
                  style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// Fungsi untuk meminta izin yang diperlukan untuk alarm
Future<void> requestPermissions() async {
  // Request notification permission first
  final notificationStatus = await Permission.notification.request();
  if (notificationStatus.isDenied) {
    debugPrint('Notification permission ditolak');
  }
  
  if (Platform.isAndroid) {
    // Request audio permissions
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isDenied) {
      debugPrint('Audio permission ditolak');
    }
    
    // Request storage permissions
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isDenied) {
      debugPrint('Storage permission ditolak');
    }
    
    // Pada Android 13+ perlu izin eksplisit untuk notifikasi
    try {
      final String androidSdk = await Alarm.androidDeviceSDK;
      if (androidSdk.isNotEmpty) {
        int? sdkVersion = int.tryParse(androidSdk);
        if (sdkVersion != null && sdkVersion >= 33) {
          // Check for specific Android 13+ permissions
          final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
          if (exactAlarmStatus.isDenied) {
            debugPrint('scheduleExactAlarm permission ditolak');
          }
          
          final notificationPolicyStatus = await Permission.accessNotificationPolicy.request();
          if (notificationPolicyStatus.isDenied) {
            debugPrint('accessNotificationPolicy permission ditolak');
          }
        }
      }
    } catch (e) {
      debugPrint('Error saat memeriksa atau meminta izin Android: $e');
    }
  }
}

// Fungsi untuk menavigasi ke AlarmRingScreen ketika alarm berbunyi
void navigateToRingScreen(AlarmSettings alarmSettings) {
  debugPrint('Alarm berbunyi: ${alarmSettings.id}');
  debugPrint('Audio path: ${alarmSettings.assetAudioPath}');
  
  // Pastikan ini dijalankan di main isolate
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Cek apakah navigator tersedia sebelum navigasi
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
        ),
      );
    } else {
      debugPrint('Navigator state tidak tersedia saat alarm berbunyi');
    }
  });
}

class Aturin extends StatefulWidget {
  const Aturin({super.key});

  @override
  State<Aturin> createState() => _AturinState();
}

class _AturinState extends State<Aturin> {
  // Inisialisasi services
  final TaskService _taskService = TaskService();
  final ProfileService _profileService = ProfileService();
  final AlarmService _alarmService = AlarmService();
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    
    // Inisialisasi data services jika diperlukan
    _initializeServices();
  }

  // Metode untuk inisialisasi services
  Future<void> _initializeServices() async {
    try {
      // Jika ada inisialisasi data yang perlu dilakukan
      await _profileService.initialize();
      await _taskService.initialize();
      await _alarmService.initialize();
    } catch (e) {
      debugPrint('Error saat inisialisasi services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _taskService),
        ChangeNotifierProvider.value(value: _profileService),
        Provider.value(value: _alarmService),
      ],
      child: MaterialApp.router(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Aturin',
        locale: const Locale('id', 'ID'), // Set locale utama ke Bahasa Indonesia
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'), // Tambahkan dukungan untuk locale lain jika diperlukan
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, // Ganti dengan warna tema aplikasi Anda
            brightness: Brightness.light,
          ),
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}