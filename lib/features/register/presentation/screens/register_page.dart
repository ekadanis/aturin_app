
import 'package:aturin_app/features/register/presentation/widgets/login_link_widget.dart';
import 'package:aturin_app/features/register/presentation/widgets/register_app_bar_widget.dart';
import 'package:aturin_app/features/register/presentation/widgets/register_form_widget.dart';
import 'package:aturin_app/features/register/presentation/widgets/register_header.dart';
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:aturin_app/shared/core/services/api/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/shared/core/infrastructure/routers/app_router.dart'; 

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
  bool _isValidationSnackbarActive = false;

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
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          backgroundColor: AppTheme.lightBackgroundColor,
          body: SafeArea(
            child: SizedBox(
              height: 100.h,
              width: 100.w,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Custom App Bar
                      RegisterAppBarWidget(
                        onBackPressed: () => context.router.pop(),
                      ),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
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
                                onRegister: () async {
                                  final authService = Provider.of<AuthService>(context, listen: false);

                                  try {
                                    final result = await authService.register(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                    );

                                    if (result.isSuccess) {
                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result.message,
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
                                    } else {
                                      // Show error message
                                      _showThrottledSnackBar(result.message);
                                    }
                                  } catch (e) {
                                    _showThrottledSnackBar('Terjadi kesalahan: ${e.toString()}');
                                  }
                                },
                                onValidationError: _showThrottledSnackBar,
                              ),

                              SizedBox(height: 3.h),

                              // Login link
                              LoginLinkWidget(onLoginTap: _navigateToLogin),

                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Loading overlay
                  if (authService.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToLogin() {
    // Replace Navigator.pushReplacement with auto_route navigation
    context.router.replace(const LoginRoute());
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