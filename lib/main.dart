import 'package:animated_splash_screen/animated_splash_screen.dart';
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
      home: AnimatedSplashScreen(
        splash: 'assets/images/splash_screen/splashscreen.gif',
        splashIconSize: double.infinity,
        centered: true,
        nextScreen: MainPage(),
        backgroundColor: Colors.white,
      ),
    );
  }
}
