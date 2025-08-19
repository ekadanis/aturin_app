import 'package:aturin_app/features/password_reset/presentation/widgets/password_reset_form.dart';
import 'package:aturin_app/features/password_reset/presentation/widgets/password_reset_header.dart';
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController emailController = TextEditingController();
  // bool _isProcessing = false;
  // bool _isValidationSnackbarActive = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        body: Stack(
          children: [
            SizedBox(
              height: 100.h,
              width: 100.w,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height:
                          kToolbarHeight + MediaQuery.of(context).padding.top,
                    ),

                    const PasswordResetHeader(),

                    SizedBox(height: 5.h),

                    PasswordResetForm(
                      emailController: emailController,
                      onSend: _handleEmail,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0), // Optional padding
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 16,
                      height: 16,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEmail() async {}


  // bool _validateInputs() {
  //   if (emailController.text.trim().isEmpty) {
  //     _showThrottledSnackBar('Email tidak boleh kosong');
  //     return false;
  //   }

  //   // Normalize email to lowercase
  //   final normalizedEmail = emailController.text.trim().toLowerCase();
  //   emailController.text = normalizedEmail;

  //   if (!RegExp(
  //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  //   ).hasMatch(normalizedEmail)) {
  //     _showThrottledSnackBar('Format email tidak valid');
  //     return false;
  //   }

  //   return true;
  // }

  // void _showThrottledSnackBar(String message) {
  //   // 1. If a validation snackbar is already visible, do nothing.
  //   if (_isValidationSnackbarActive) return;

  //   // 2. Set the flag to true and clear any previous snackbars.
  //   setState(() => _isValidationSnackbarActive = true);

  //   // 3. Gunakan custom top SnackBar untuk validation error
  //   showCustomTopSnackbar(context: context, message: message, isError: true);

  //   // 4. Reset flag setelah delay
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (mounted) {
  //       setState(() => _isValidationSnackbarActive = false);
  //     }
  //   });
  // }
}
