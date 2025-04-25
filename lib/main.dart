import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aturin_app/routers/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const Aturin());
}

class Aturin extends StatelessWidget {
  const Aturin({super.key});

  @override
  Widget build(BuildContext context) {
      final appRouter = AppRouter();

      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Aturin',
        theme: ThemeData(
          useMaterial3: true,
        ),
        routerConfig: appRouter.config(),
        // Hapus builder dan ganti dengan routerDelegate & routeInformationParser
      );
  }
}