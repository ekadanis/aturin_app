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
  bool get hasSymbol => widget.passwordController.text.contains(RegExp(r'[!@#\$&*~._-]'));
  bool get hasMinLength => widget.passwordController.text.length >= 8;
  bool get noSpaces => !widget.passwordController.text.contains(' ');
  bool get isNotEmpty => widget.passwordController.text.isNotEmpty;

  double get strengthValue {
    int passed = [hasUppercase, hasSymbol, hasMinLength, noSpaces, isNotEmpty]
        .where((e) => e)
        .length;
    return passed / 5;
  }

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(() => setState(() {}));
    widget.confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Input
        _buildInputLabel('Nama'),
        SizedBox(height: 1.h),
        CustomTextFieldWidget(
          controller: widget.nameController,
          hintText: 'Masukkan Nama',
          icon: Icons.person_outline,
          obscureText: false,
        ),
        
        SizedBox(height: 2.h),        // Email Input
        _buildInputLabel('Email'),
        SizedBox(height: 1.h),
        CustomTextFieldWidget(
          controller: widget.emailController,
          hintText: 'contoh@gmail.com',
          icon: Icons.email_outlined,
          obscureText: false,
        ),
        
        SizedBox(height: 2.h),
        
        // Password Input
        _buildInputLabel('Kata Sandi'),
        SizedBox(height: 1.h),
        PasswordFieldWidget(
          controller: widget.passwordController,
          isPasswordVisible: isPasswordVisible,
          onVisibilityToggle: () {
            setState(() => isPasswordVisible = !isPasswordVisible);
          },
        ),
        
        SizedBox(height: 2.h),
        
        // Confirm Password Input
        _buildInputLabel('Konfirmasi Kata Sandi'),
        SizedBox(height: 1.h),
        ConfirmPasswordFieldWidget(
          controller: widget.confirmPasswordController,
          passwordController: widget.passwordController,
          isPasswordVisible: isPasswordVisible,
        ),
        
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
            onPressed: () {
              if (_validateForm()) {
                widget.onRegister();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
            ),
            child: Text(
              "Daftar",
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

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppTheme.lightTextColor,
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
    
    if (strengthValue < 1.0) {
      widget.onValidationError('Password belum memenuhi semua kriteria');
      return false;
    }
    
    if (widget.passwordController.text != widget.confirmPasswordController.text) {
      widget.onValidationError('Konfirmasi kata sandi tidak cocok');
      return false;
    }
    
    return true;
  }
}