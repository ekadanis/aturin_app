import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal untuk locale 'id_ID' (Indonesia)
  await initializeDateFormatting('id_ID', null);
  
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

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskService()),
          ChangeNotifierProvider(create: (_) => ProfileService()),
        ],
        child: MaterialApp.router(
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
          ),
          routerConfig: appRouter.config(),
        ),
      );
  }
}