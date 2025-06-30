import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/auth/login/widgets/custom_text_field.dart';
import 'package:aturin_app/features/auth/register/widgets/confirm_password_field_widget.dart';
import 'package:aturin_app/features/auth/register/widgets/password_field_widget.dart';
import 'package:aturin_app/features/auth/register/widgets/password_stregth_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RegisterFormWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;
  final Function(String) onValidationError;

  const RegisterFormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
    required this.onValidationError,
  });

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  bool isPasswordVisible = false;
  // Password validation getters
  bool get hasUppercase => widget.passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasSymbol => widget.passwordController.text.contains(RegExp(r'''[!@#\$%^&*()_+=\[\]{}|;:,.<>?~`'"/-]'''));
  bool get hasMinLength => widget.passwordController.text.length >= 8;
  bool get noSpaces => !widget.passwordController.text.contains(' ');
  bool get isNotEmpty => widget.passwordController.text.isNotEmpty;

  double get strengthValue {
    int passed = [hasUppercase, hasSymbol, hasMinLength, noSpaces, isNotEmpty]
        .where((e) => e)
        .length;
    return passed / 5;
  }

  // Form validation for button state
  bool get isFormValid {
    return widget.nameController.text.trim().isNotEmpty &&
           widget.emailController.text.trim().isNotEmpty &&
           widget.passwordController.text.length >= 8 &&
           widget.passwordController.text == widget.confirmPasswordController.text;
  }
  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers for button state
    widget.nameController.addListener(() => setState(() {}));
    widget.emailController.addListener(() => setState(() {}));
    widget.passwordController.addListener(() => setState(() {}));
    widget.confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        // Name Input
        _buildInputLabel('Nama', isRequired: true),
        SizedBox(height: 1.h),
        CustomTextFieldWidget(
          controller: widget.nameController,
          hintText: 'Masukkan Nama',
          icon: Icons.person_outline,
          obscureText: false,
        ),
        
        SizedBox(height: 2.h),
        _buildInputLabel('Email', isRequired: true),
        SizedBox(height: 1.h),
        CustomTextFieldWidget(
          controller: widget.emailController,
          hintText: 'contoh@gmail.com',
          icon: Icons.email_outlined,
          obscureText: false,
        ),
        
        SizedBox(height: 2.h),
        
        // Password Input
        _buildInputLabel('Kata Sandi', isRequired: true),
        SizedBox(height: 1.h),
        PasswordFieldWidget(
          controller: widget.passwordController,
          isPasswordVisible: isPasswordVisible,          onVisibilityToggle: () {
            setState(() => isPasswordVisible = !isPasswordVisible);
          },
        ),
        
        SizedBox(height: 2.h),
        
        // Confirm Password Input
        _buildInputLabel('Konfirmasi Kata Sandi', isRequired: true),
        SizedBox(height: 1.h),        ConfirmPasswordFieldWidget(
          controller: widget.confirmPasswordController,
          passwordController: widget.passwordController,
          isPasswordVisible: isPasswordVisible,
        ),
        
        // Password match indicator
        if (widget.confirmPasswordController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                Icon(
                  widget.passwordController.text == widget.confirmPasswordController.text
                      ? Icons.check_circle
                      : Icons.error,
                  color: widget.passwordController.text == widget.confirmPasswordController.text
                      ? AppTheme.successColor
                      : AppTheme.lightErrorColor,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  widget.passwordController.text == widget.confirmPasswordController.text
                      ? 'Password cocok'
                      : 'Password tidak cocok',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: widget.passwordController.text == widget.confirmPasswordController.text
                        ? AppTheme.successColor
                        : AppTheme.lightErrorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Password Strength Indicator
        if (widget.passwordController.text.isNotEmpty) ...[
          SizedBox(height: 2.h),
          PasswordStrengthWidget(
            strengthValue: strengthValue,
            hasUppercase: hasUppercase,
            hasSymbol: hasSymbol,
            hasMinLength: hasMinLength,
            noSpaces: noSpaces,
            isNotEmpty: isNotEmpty,
          ),
        ],
        
        SizedBox(height: 4.h),
          // Register Button
        SizedBox(
          width: 100.w,
          height: 6.h,
          child: ElevatedButton(
            onPressed: isFormValid ? () {
              if (_validateForm()) {
                widget.onRegister();
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid 
                  ? AppTheme.primaryColor 
                  : AppTheme.disabledColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isFormValid ? 4 : 0,
              shadowColor: isFormValid 
                  ? AppTheme.primaryColor.withOpacity(0.4) 
                  : Colors.transparent,
            ),
            child: Text(
              "Daftar",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isFormValid 
                    ? Colors.white 
                    : AppTheme.disabledTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTextColor,
            ),
          ),
          if (isRequired)
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
    );
  }
  bool _validateForm() {
    if (widget.nameController.text.trim().isEmpty) {
      widget.onValidationError('Nama tidak boleh kosong');
      return false;
    }
    
    if (widget.emailController.text.trim().isEmpty) {
      widget.onValidationError('Email tidak boleh kosong');
      return false;
    }
    
    // Normalize email to lowercase
    final normalizedEmail = widget.emailController.text.trim().toLowerCase();
    widget.emailController.text = normalizedEmail;
    
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(normalizedEmail)) {
      widget.onValidationError('Format email tidak valid');
      return false;
    }
    
    if (widget.passwordController.text.trim().isEmpty) {
      widget.onValidationError('Password tidak boleh kosong');
      return false;
    }
      if (widget.passwordController.text.length < 8) {
      widget.onValidationError('Password minimal 8 karakter');
      return false;
    }
    
    if (widget.passwordController.text != widget.confirmPasswordController.text) {
      widget.onValidationError('Konfirmasi kata sandi tidak cocok');
      return false;
    }
    
    return true;
  }
}