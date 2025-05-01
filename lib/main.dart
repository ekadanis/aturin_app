import 'package:flutter/material.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:aturin_app/features/alarm/services/alarm_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aturin_app/core/initialization/app_initializer.dart';

// AppRouter yang akan diakses dari seluruh aplikasi
final AppRouter appRouter = AppRouter();
// App initializer untuk mengatur startup aplikasi
final AppInitializer appInitializer = AppInitializer(appRouter);

void main() async {
  // Pastikan ini dipanggil sebelum mengakses Flutter services
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inisialisasi semua komponen aplikasi melalui app initializer
    await appInitializer.initialize();
    
    // Set app creator untuk alarm manager
    appInitializer.alarmManager.setAppCreator(() => const Aturin());
    
    // Jalankan aplikasi
    runApp(const Aturin());
  } catch (e) {
    // Menangkap dan mencatat error yang terjadi selama inisialisasi
    debugPrint('Error selama inisialisasi aplikasi: $e');
    // Jalankan aplikasi dengan pesan error jika diperlukan
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

  @override
  void initState() {
    super.initState();
    // Alarm already initialized by AppInitializer, no need for duplicate initialization
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
        debugShowCheckedModeBanner: false,
        title: 'Aturin',
        locale: const Locale('id', 'ID'),
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        routerConfig: appRouter.config(),
      ),
    );
  }
}