import 'package:flutter/material.dart';
import 'package:aturin_app/Test/main_page.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aturin',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainPage(),
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
