
import 'package:aturin_app/features/login/presentation/widgets/custom_text_field.dart';
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final bool isLoading;
  final VoidCallback onPasswordResetTap;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    this.isLoading = false,
    required this.onPasswordResetTap, // default false
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.emailController,
      builder: (context, emailValue, child) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.passwordController,
          builder: (context, passwordValue, child) {
            final isFormValid =
                emailValue.text.trim().isNotEmpty &&
                passwordValue.text.trim().isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Input Section
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Email',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      TextSpan(
                        text: ' *',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightErrorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                CustomTextFieldWidget(
                  controller: widget.emailController,
                  hintText: 'contoh@gmail.com',
                  icon: Icons.email_outlined,
                  obscureText: false,
                ),

                SizedBox(height: 2.5.h), // Password Input Section
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Kata Sandi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      TextSpan(
                        text: ' *',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightErrorColor,
                        ),
                      ),
                    ],
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
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                      backgroundColor:
                          isFormValid
                              ? AppTheme.primaryColor
                              : AppTheme.disabledColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isFormValid ? 4 : 0,
                      shadowColor:
                          isFormValid
                              ? AppTheme.primaryColor.withOpacity(0.4)
                              : Colors.transparent,
                    ),
                    onPressed: isFormValid ? widget.onLogin : null,
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            isFormValid
                                ? Colors.white
                                : AppTheme.disabledTextColor,
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: widget.onPasswordResetTap,
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
