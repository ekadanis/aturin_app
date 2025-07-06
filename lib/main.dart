import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
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
    
    // Initialize home widget interaction handler
    _initializeHomeWidgetCallbacks();
    
    // Inisialisasi aplikasi menggunakan AppBootstrap
    final bootstrap = AppBootstrap(
      appRouter: appRouter,
      connectivityService: connectivityService,
      appCreator: () => MyApp(
        appRouter: appRouter,
        connectivityService: connectivityService,
      ),
    );
    
    // Mulai dengan app loader terlebih dahulu
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PreloadingApp(
          bootstrap: bootstrap,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    AppBootstrap.removeSplashScreen();
    runApp(ErrorApp(error: e.toString()));
  }
}

/// Widget untuk menangani proses preloading
class PreloadingApp extends StatefulWidget {
  final AppBootstrap bootstrap;

  const PreloadingApp({Key? key, required this.bootstrap}) : super(key: key);

  @override
  State<PreloadingApp> createState() => _PreloadingAppState();
}

class _PreloadingAppState extends State<PreloadingApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inisialisasi bootstrap dengan sangat cepat
      await widget.bootstrap.initialize();
      
      // Tunggu sebentar untuk splash screen yang natural (minimal delay)
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Hapus splash screen dan jalankan aplikasi utama
      AppBootstrap.removeSplashScreen();
      runApp(MyApp(
        appRouter: appRouter,
        connectivityService: connectivityService,
      ));
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      
      // Tunggu sebentar dan tampilkan error
      await Future.delayed(const Duration(seconds: 1));
      AppBootstrap.removeSplashScreen();
      runApp(ErrorApp(error: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget ini sengaja kosong karena menggunakan native splash screen
    return Container(
      color: Colors.transparent,
    );
  }
}

/// Initialize home widget interaction callbacks
void _initializeHomeWidgetCallbacks() {
  HomeWidget.widgetClicked.listen((Uri? uri) {
    if (uri != null) {
      _handleWidgetInteraction(uri);
    }
  });
  
  debugPrint('🏠 Widget interaction handler initialized');
}

/// Handle interaction from home widget
void _handleWidgetInteraction(Uri uri) {
  final action = uri.queryParameters['action'];
  debugPrint('🏠 Widget interaction received: $action');
  
  // Store action untuk diproses oleh app saat sudah siap
  _storeWidgetAction(action);
}

/// Store widget action untuk diproses setelah app selesai inisialisasi
void _storeWidgetAction(String? action) {
  if (action == null) return;
  
  debugPrint('🏠 Widget action stored: $action');
  
  // Simpan action dalam preferences sementara untuk diproses oleh app
  HomeWidget.saveWidgetData<String>('pending_action', action);
  HomeWidget.saveWidgetData<int>('pending_action_time', DateTime.now().millisecondsSinceEpoch);
}
