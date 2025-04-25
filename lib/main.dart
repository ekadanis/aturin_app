import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aturin_app/routers/app_router.dart';
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

  Future<bool> _shouldShowOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    final _appRouter = AppRouter();

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
        nextScreen: FutureBuilder<bool>(
          future: _shouldShowOnboarding(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading screen'));
            } else {
              // If isFirstTime is true, show onboarding, else show main app with router
              return snapshot.data! 
                ? const OnboardingScreen()
                : MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    routerConfig: _appRouter.config(),
                  );
            }
          },
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}