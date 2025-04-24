import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/Test/main_page.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aturin_app/features/onboarding/ui/onboarding_screen.dart';

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

  Future<Widget>_getInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      return const OnboardingScreen();
    } else {
      return const MainPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aturin',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen(
        //Nungguin GIF dari mas Zap
        splash: 'assets/images/splash_screen/splashscreen.gif',
        splashIconSize: double.infinity,
        centered: true,
        nextScreen: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading screen'));
            } else {
              return snapshot.data!;
            }
          },
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
