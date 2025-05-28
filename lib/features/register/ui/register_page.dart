import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/login/ui/login_page.dart';
import 'package:aturin_app/features/register/widgets/login_link_widget.dart';
import 'package:aturin_app/features/register/widgets/register_app_bar_widget.dart';
import 'package:aturin_app/features/register/widgets/register_form_widget.dart';
import 'package:aturin_app/features/register/widgets/register_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
          child: Column(
            children: [
              // Custom App Bar
              RegisterAppBarWidget(
                onBackPressed: () => Navigator.pop(context),
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      
                      // Header with illustration and title
                      const RegisterHeaderWidget(),
                      
                      SizedBox(height: 3.h),
                      
                      // Registration form
                      RegisterFormWidget(
                        nameController: nameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        onRegister: _handleRegister,
                        onValidationError: _showSnackBar,
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Login link
                      LoginLinkWidget(
                        onLoginTap: _navigateToLogin,
                      ),
                      
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pendaftaran berhasil! Silakan masuk dengan akun Anda.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to login page after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}