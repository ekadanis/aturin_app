import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/database/database_helper.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _controller.forward();

    _initializeData();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // Memastikan database sudah diinisialisasi sebelum melanjutkan
      await DatabaseHelper.instance.database;

      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;
      _checkFirstTime();
    } catch (e) {
      debugPrint("Error initializing database: $e");
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) _checkFirstTime();
    }
  }

  Future<void> _checkFirstTime() async {
    if (!mounted) return;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (!mounted) return;

      if (isFirstTime) {
        context.router.replace(const OnboardingRoute());
      } else {
        context.router.replace(const HomeRoute());
      }
    } catch (e) {
      debugPrint("Error checking first time: $e");
      if (mounted) {
        context.router.replace(const OnboardingRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/images/splash_screen/splashscreen.gif',
                fit: BoxFit.contain,
                width: 95.w,
              ),
            ),
          ),
        );
      },
    );
  }
}