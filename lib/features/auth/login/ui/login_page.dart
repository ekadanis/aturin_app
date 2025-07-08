import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/auth/login/widgets/login_divider_widget.dart';
import 'package:aturin_app/features/auth/login/widgets/login_form_widget.dart';
import 'package:aturin_app/features/auth/login/widgets/login_header_widget.dart';
import 'package:aturin_app/features/auth/login/widgets/register_link_widget.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/services/api/auth/auth_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isProcessing = false;
  bool _isValidationSnackbarActive = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),

                // Header with logo and title
                const LoginHeaderWidget(),

                SizedBox(height: 5.h),

                // Login form
                LoginFormWidget(
                  emailController: emailController,
                  passwordController: passwordController,
                  onLogin: _handleLogin,
                  isLoading: _isProcessing,
                ),

                SizedBox(height: 3.h),

                // Divider
                const LoginDividerWidget(),

                SizedBox(height: 3.h),

                // Google login button
                // GoogleLoginButtonWidget(
                //   onGoogleLogin: _handleGoogleLogin,
                // ),
                SizedBox(height: 3.h),

                // Register link
                RegisterLinkWidget(onRegisterTap: _navigateToRegister),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _handleLogin() async {
  //   if (_isProcessing) return; // Hindari multiple tap
  //   setState(() => _isProcessing = true);

  //   if (!_validateInputs()) {
  //     setState(() => _isProcessing = false);
  //     return;
  //   }

  //   final authService = Provider.of<AuthService>(context, listen: false);

  //   try {
  //     // Call the API login service
  //     final result = await authService.login(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );

  //     if (result.isSuccess && mounted) {
  //       // Save login data
  //       await _saveLoginData(result);

  //       // Navigate to home page using AutoRouter
  //       context.router.replaceAll([const HomeRoute()]);

  //       // Show success message
  //       _showSnackBar(result.message, isSuccess: true);
  //     } else {
  //       // Show error message
  //       _showSnackBar(result.message);
  //     }
  //   } catch (e) {
  //     _showSnackBar('Terjadi kesalahan: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //     }
  //   }
  // }

  Future<void> _handleLogin() async {
    if (_isProcessing) return; // Hindari multiple tap
    setState(() => _isProcessing = true);

    if (!_validateInputs()) {
      setState(() => _isProcessing = false);
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final result = await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result.isSuccess && mounted) {
        await _saveLoginData(result);

        _showSnackBar(result.message, isSuccess: true);
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // beri waktu snackbar muncul

        if (mounted) {
          context.router.replaceAll([const HomeRoute()]);
        }
      } else {
        _showSnackBar(result.message);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _navigateToRegister() {
    context.router.push(const RegisterRoute());
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      _showThrottledSnackBar('Email tidak boleh kosong');
      return false;
    }

    // Normalize email to lowercase
    final normalizedEmail = emailController.text.trim().toLowerCase();
    emailController.text = normalizedEmail;

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(normalizedEmail)) {
      _showThrottledSnackBar('Format email tidak valid');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showThrottledSnackBar('Password tidak boleh kosong');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showThrottledSnackBar('Password minimal 6 karakter');
      return false;
    }

    return true;
  }

  void _showThrottledSnackBar(String message) {
    // 1. If a validation snackbar is already visible, do nothing.
    if (_isValidationSnackbarActive) return;

    // 2. Set the flag to true and clear any previous snackbars.
    setState(() => _isValidationSnackbarActive = true);
    ScaffoldMessenger.of(context).clearSnackBars();

    // 3. Show the snackbar and wait for it to close.
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightErrorColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(4.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 3),
          ),
        )
        .closed // This future completes when the snackbar is gone
        .then((_) {
          // 4. When it closes, reset the flag.
          if (mounted) {
            setState(() => _isValidationSnackbarActive = false);
          }
        });
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    final messenger = ScaffoldMessenger.of(context);

    // Bersihkan semua snackbar sebelumnya
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: isSuccess ? Colors.green : AppTheme.lightErrorColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveLoginData(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (result.user != null) {
      await prefs.setString('userEmail', result.user!.email);
      await prefs.setString('userName', result.user!.name);
      await prefs.setString('userId', result.user!.id.toString());
    }
    if (result.token != null) {
      await prefs.setString('token', result.token!);
    }
    await prefs.setString('loginTime', DateTime.now().toIso8601String());
  }
}
