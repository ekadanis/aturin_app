import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/routers/app_router.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      _checkFirstTime();
    });
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    
    if (!mounted) return;

    if (isFirstTime) {
      context.router.replace(const OnboardingRoute());
    } else {
      context.router.replace(const HomeRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/images/splash_screen/splashscreen.gif',
      splashIconSize: double.infinity,
      centered: true,
      duration: 3000,
      nextScreen: const Scaffold(
        backgroundColor: Colors.white,
      ),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }
}