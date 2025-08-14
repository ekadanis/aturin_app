import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/auth/login/widgets/custom_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PasswordResetForm extends StatefulWidget {
  final TextEditingController emailController;
  final VoidCallback onSend;
  final bool isLoading;

  const PasswordResetForm({
    super.key,
    required this.emailController,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<PasswordResetForm> createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.emailController,
      builder: (context, emailValue, child) {
        final isFormValid = emailValue.text.trim().isNotEmpty;
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
                onPressed: isFormValid ? widget.onSend : null,
                child: Text(
                  'Kirim Tautan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isFormValid ? Colors.white : AppTheme.disabledTextColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
