import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aturin_app/routers/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(Aturin());
}

class Aturin extends StatelessWidget {
  Aturin({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aturin',
      theme: ThemeData(
        useMaterial3: true,
      ),
      routerConfig: _appRouter.config(),
      /*
      routes: {
        '/homepage': (context) => const HomePage(),
        '/taskpage': (context) => const TaskPage(),
        '/profilepage': (context) => const ProfilePage(),
      },
      */
    );
  }
}
