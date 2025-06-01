import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create fade animation
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start animation
    _controller.forward();

    // Initialize app data and navigation
    _initializeData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // Wait for minimum splash duration to show the splash screen
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      // Navigate to appropriate screen
      await _checkFirstTime();
    } catch (e) {
      debugPrint("Error initializing data: $e");

      // Fallback delay if error occurs
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        await _checkFirstTime();
      }
    }
  }

  Future<void> _checkFirstTime() async {
    if (!mounted) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (!mounted) return;

      // Navigate based on first time status
      if (isFirstTime) {
        context.router.replace(const OnboardingRoute());
      } else {
        context.router.replace(const HomeRoute());
      }
    } catch (e) {
      debugPrint("Error checking first time status: $e");

      // Default to onboarding if error occurs
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
          body: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/images/splash_screen/splashscreen.gif',
                  fit: BoxFit.contain,
                  width: 95.w,
                  // Add error handling for image loading
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error_outline,
                      size: 50.sp,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
