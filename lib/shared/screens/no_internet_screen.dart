import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:aturin_app/shared/core/services/connectivity/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sizer/sizer.dart';

import '../core/infrastructure/routers/app_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _connectivityService.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_connectivityService.isConnected && mounted) {
      // Internet is back, return to previous page or home
      _returnToPreviousPage();
    }
  }

  void _returnToPreviousPage() {
    if (context.router.canPop()) {
      // Return to previous page
      context.router.maybePop();
    } else {
      // If can't pop, navigate to home and clear stack
      context.router.pushAndPopUntil(
        const HomeRoute(),
        predicate: (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Header Text
              Text(
                'Waduh, Koneksi Internetmu Hilang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),              // No Internet Image
              Expanded(
                flex: 1,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/no_internet/no_internet.svg',
                    fit: BoxFit.contain,
                    height: 25.h,
                  ),
                ),
              ),

              SizedBox(height: 1.2.h), // Reduced from 6.h to bring text closer

              // Description Text
              Text(
                'Waktumu berharga — yuk online lagi\nsupaya kita bisa bantu.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkBackgroundColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h), // Reduced from 6.h

              // Reload Button
              SizedBox(
                width: 40.w,
                height: 7.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleReload(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 3.h,
                          width: 3.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Muat ulang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 4.h), // Reduced from 6.h
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleReload(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // First check basic connectivity
      final hasConnectivity =
          await _connectivityService.checkConnectivityManually();
      if (hasConnectivity) {
        // Test connectivity to the server
        final isServerReachable = await _connectivityService
            .testServerConnection('https://aturin-app.com/api');

        if (isServerReachable) {
          // Internet and server are available, return to previous page
          _returnToPreviousPage();
        } else {
          // Internet is available but server is not reachable
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Server tidak dapat dijangkau. Coba lagi.',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                backgroundColor: Colors.orange[400],
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // Still no internet connection
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Masih tidak ada koneksi internet. Coba lagi.',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.red[400],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memeriksa koneksi. Coba lagi.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red[400],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}