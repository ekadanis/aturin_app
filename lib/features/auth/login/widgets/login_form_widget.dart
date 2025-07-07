import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/auth/login/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    this.isLoading = false, // default false
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Input Section
        Text(
          'Email',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTextColor,
          ),
        ),
        SizedBox(height: 1.h),
        CustomTextFieldWidget(
          controller: widget.emailController,
          hintText: 'contoh@gmail.com',
          icon: Icons.email_outlined,
          obscureText: false,
        ),

        SizedBox(height: 2.5.h),

        // Password Input Section
        Text(
          'Kata Sandi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTextColor,
          ),
        ),
        SizedBox(height: 1.h),
        CustomTextFieldWidget(
          controller: widget.passwordController,
          hintText: '****************',
          icon: Icons.vpn_key,
          obscureText: !isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              size: 20.sp,
            ),
            onPressed: () {
              setState(() => isPasswordVisible = !isPasswordVisible);
            },
          ),
        ),

        SizedBox(height: 4.h),

        // Login Button
        SizedBox(
          width: 100.w,
          height: 6.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
            ),
            onPressed: widget.isLoading ? null : widget.onLogin,
            child:
                widget.isLoading
                    ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      'Masuk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
