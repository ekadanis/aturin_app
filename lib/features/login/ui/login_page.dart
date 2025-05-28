import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/home/ui/page/home_page.dart';
import 'package:aturin_app/features/login/widgets/google_login_button.dart';
import 'package:aturin_app/features/login/widgets/login_divider_widget.dart';
import 'package:aturin_app/features/login/widgets/login_form_widget.dart';
import 'package:aturin_app/features/login/widgets/login_header_widget.dart';
import 'package:aturin_app/features/login/widgets/register_link_widget.dart';
import 'package:aturin_app/features/register/ui/register_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                RegisterLinkWidget(
                  onRegisterTap: _navigateToRegister,
                ),
                
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_validateInputs()) {
      await _saveLoginStatus();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    // TODO: Implement Google Sign-In logic
    try {
      // Add your Google Sign-In implementation here
      // For now, we'll simulate a successful login
      await _saveLoginStatus();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      _showSnackBar('Google login failed: $e');
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      _showSnackBar('Email tidak boleh kosong');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      _showSnackBar('Format email tidak valid');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showSnackBar('Password tidak boleh kosong');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showSnackBar('Password minimal 6 karakter');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
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
    );
  }

  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', emailController.text.trim());
    await prefs.setString('loginTime', DateTime.now().toIso8601String());
  }
}