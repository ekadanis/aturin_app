import 'package:aturin_app/core/services/api/profile/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:aturin_app/features/task/services/task_services.dart' as task;
import 'package:aturin_app/features/home/services/home_service.dart';
import 'package:aturin_app/core/services/api/profile/profile_service.dart';
import 'package:aturin_app/core/services/api/auth/auth_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/features/jadwal/services/aktivitas_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/initialization/app_initializer.dart';
import 'core/database/database_helper.dart';
import 'routers/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/connectivity/connectivity_service.dart';
import 'core/services/api/task/task_api_service.dart';

// Membuat instance AppRouter dan ConnectivityService di level global
final appRouter = AppRouter();
final connectivityService = ConnectivityService();

Future<void> main() async {
  // Preserve splash screen until initialization is complete
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Set orientasi hanya potrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await _initializeApp();
    final app = const MyApp();
    FlutterNativeSplash.remove();
    runApp(app);
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    FlutterNativeSplash.remove();
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> _initializeApp() async {
  try {
    // Initialize connectivity service first (highest priority)
    await connectivityService.initialize();
    debugPrint('Connectivity service initialized successfully');

    await initializeDateFormatting('id_ID', null);
    debugPrint('Date formatting initialized for id_ID locale');

    // Only proceed with other initializations if we have internet
    if (connectivityService.isConnected) {
      // Initialize the app with AppInitializer
      final appInitializer = AppInitializer(appRouter);
      await appInitializer.initialize();

      // Setup alarm manager
      appInitializer.alarmManager.setAppCreator(() => const MyApp());

      // Handle login routing only if online
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        appRouter.replaceAll([const HomeRoute()]);
      } else {
        appRouter.replaceAll([const LoginRoute()]);
      }
    } else {
      // If offline, navigate directly to NoInternetScreen
      debugPrint(
        'No internet connection detected, navigating to NoInternetScreen',
      );
      appRouter.replaceAll([const NoInternetRoute()]);
    }
  } catch (e) {
    debugPrint('Failed to initialize app: $e');
    throw Exception('App initialization failed: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivityService,
        ),
        // Provider untuk AuthService
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        // Provider untuk TaskService dari features/task (untuk backward compatibility)
        ChangeNotifierProvider<task.TaskService>(
          create: (_) => task.TaskService(),        ),        // Provider untuk HomeService (unified service for home page)
        ChangeNotifierProvider<HomeService>(create: (_) => HomeService()),        // Provider untuk ActivityApiService
        ChangeNotifierProvider<ActivityApiService>(
          create: (_) => ActivityApiService(),
        ),
        // Provider untuk AktivitasService (for add/edit operations)
        ChangeNotifierProvider<AktivitasService>(
          create: (_) => AktivitasService(),
        ),
        // Provider untuk ProfileService
        ChangeNotifierProvider<ProfileService>(create: (_) => ProfileService()),
        // Provider untuk TaskApiService
        ChangeNotifierProvider<TaskApiService>(create: (_) => TaskApiService()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp.router(
            title: 'Aturin',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.config(),
          );
        },
      ),
    );
  }
}

// ErrorApp class implementation remains the same
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Aturin - Error',
          theme: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              error: Colors.red,
            ),
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 10.h),
                    SizedBox(height: 2.h),
                    Text(
                      'Terjadi kesalahan saat memulai aplikasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await DatabaseHelper.instance.resetDatabase();
                              main();
                            } catch (e) {
                              debugPrint('Error resetting database: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Reset Database'),
                        ),
                        SizedBox(width: 4.w),
                        ElevatedButton(
                          onPressed: () {
                            main();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
