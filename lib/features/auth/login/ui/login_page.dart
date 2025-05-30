import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/core/services/api/auth/auth_service.dart';
import 'package:aturin_app/features/auth/login/widgets/login_divider_widget.dart';
import 'package:aturin_app/features/auth/login/widgets/login_form_widget.dart';
import 'package:aturin_app/features/auth/login/widgets/login_header_widget.dart';
import 'package:aturin_app/features/auth/login/widgets/register_link_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/routers/app_router.dart';

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
                
                // Login form with loading state from AuthService
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return LoginFormWidget(
                      emailController: emailController,
                      passwordController: passwordController,
                      onLogin: _handleLogin,
                      isLoading: authService.isLoading,
                    );
                  },
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
    if (!_validateInputs()) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final result = await authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    
    if (mounted) {
      if (result.isSuccess) {        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', result.user!.id ?? 0);
        await prefs.setString('userName', result.user!.name);
        await prefs.setString('userEmail', result.user!.email);
        if (result.token != null) {
          await prefs.setString('userToken', result.token!);
        }
        await prefs.setString('loginTime', DateTime.now().toIso8601String());
        
        // Navigate to home using router
        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (_) => false,
        );
      } else {
        _showSnackBar(result.message);
      }
    }
  }

  void _navigateToRegister() {
    context.router.push(const RegisterRoute());
  }
  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      _showSnackBar('Email tidak boleh kosong');
      return false;
    }

    // Normalize email to lowercase
    final normalizedEmail = emailController.text.trim().toLowerCase();
    emailController.text = normalizedEmail;

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(normalizedEmail)) {
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
}