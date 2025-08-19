import 'package:aturin_app/my_app.dart';
import 'package:aturin_app/shared/core/initialization/app_bootstrap.dart';
import 'package:aturin_app/shared/core/services/connectivity/connectivity_service.dart';
import 'package:aturin_app/shared/widgets/error_app.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'shared/core/infrastructure/routers/app_router.dart';


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
      await Future.delayed(const Duration(seconds: 1));
      AppBootstrap.removeSplashScreen();
      runApp(ErrorApp(error: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
    );
  }
}

void _initializeHomeWidgetCallbacks() {
  HomeWidget.widgetClicked.listen((Uri? uri) {
    if (uri != null) {
      _handleWidgetInteraction(uri);
    }
  });
  
}

/// Handle interaction from home widget
void _handleWidgetInteraction(Uri uri) {
  final action = uri.queryParameters['action'];
  
  // Store action untuk diproses oleh app saat sudah siap
  _storeWidgetAction(action);
}

/// Store widget action untuk diproses setelah app selesai inisialisasi
void _storeWidgetAction(String? action) {
  if (action == null) return;
  
  
  // Simpan action dalam preferences sementara untuk diproses oleh app
  HomeWidget.saveWidgetData<String>('pending_action', action);
  HomeWidget.saveWidgetData<int>('pending_action_time', DateTime.now().millisecondsSinceEpoch);
}
