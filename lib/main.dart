import 'package:flutter/material.dart';
import 'core/initialization/app_bootstrap.dart';
import 'core/app/my_app.dart';
import 'core/widgets/error_app.dart';
import 'routers/app_router.dart';
import 'core/services/connectivity/connectivity_service.dart';


final appRouter = AppRouter();
final connectivityService = ConnectivityService();

Future<void> main() async {
  try {
    // Preserve splash screen dan inisialisasi
    AppBootstrap.preserveSplashScreen();
    
    // Set orientasi portrait
    await AppBootstrap.setPortraitOrientation();
    
    // Inisialisasi aplikasi menggunakan AppBootstrap
    final bootstrap = AppBootstrap(
      appRouter: appRouter,
      connectivityService: connectivityService,
      appCreator: () => MyApp(
        appRouter: appRouter,
        connectivityService: connectivityService,
      ),
    );
    
    await bootstrap.initialize();
    
    // Remove splash screen dan jalankan aplikasi
    AppBootstrap.removeSplashScreen();
    runApp(MyApp(
      appRouter: appRouter,
      connectivityService: connectivityService,
    ));
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    AppBootstrap.removeSplashScreen();
    runApp(ErrorApp(error: e.toString()));
  }
}
