import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:aturin_app/shared/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:aturin_app/shared/core/infrastructure/routers/app_router.dart';


class BottomNavbar extends StatefulWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with SingleTickerProviderStateMixin {
  final _navigationThrottle = Throttle(milliseconds: 800);
  bool _isRotated = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == widget.currentIndex) return;

    _navigationThrottle.run(() {
      switch (index) {
        case 0:
          context.router.replace(const HomeRoute());
          break;
        case 1:
          context.router.replace(const AktivitasRoute());
          break;
        case 2:
          context.router.replace(const TaskListRoute());
          break;
        case 3:
          context.router.replace(const ProfileRoute());
          break;
      }
    });
  }

  @override
  void dispose() {
    _navigationThrottle.dispose();
    super.dispose();
  }

  Widget _buildSvgIcon(String assetPath, Color color, {double size = 24}) {
    return SvgPicture.asset(
      assetPath,
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  Widget _buildFloatingFABWithTooltip({
    required VoidCallback onTap,
    required String iconPath,
    required bool isVisible,
    required String tooltipText,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isVisible ? 1.0 : 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tooltip
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isVisible ? 1.0 : 0.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                tooltipText,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.8.h),
          // FAB Kiri/Kanan
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6.w),
                splashColor: Colors.white.withOpacity(0.3),
                onTap: isVisible ? onTap : null,
                child: Center(
                  child: _buildSvgIcon(
                    iconPath,
                    AppTheme.buttonBackgroundColor,
                    size: 4.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double offsetX = 0,
  }) {
    return Expanded(
      child: Transform.translate(
        offset: Offset(offsetX, 0),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSvgIcon(
                iconPath,
                isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.buttonBackgroundColor,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color:
                      isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.buttonBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fabSpacing = 25.w;
    final minSpacing = 15.w;
    final maxSpacing = 35.w;

    final leftPosition = (55.w - fabSpacing).clamp(minSpacing, maxSpacing);
    final rightPosition = (55.w - fabSpacing).clamp(minSpacing, maxSpacing);

    return SafeArea(
      top: false, // Tidak perlu padding atas
      child: Stack(
      children: [
        // Backdrop barrier saat FAB aktif
        if (_isRotated)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isRotated = false;
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),
          ),

        // Bottom Navigation Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: kBottomNavigationBarHeight + 2.h,
            decoration: BoxDecoration(
              color: AppTheme.lightCardColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: AppTheme.lightSecondaryTextColor.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Beranda
                _buildNavItem(
                  iconPath: 'assets/icons/home-simple.svg',
                  label: 'Beranda',
                  isSelected: widget.currentIndex == 0,
                  onTap: () => _handleNavigation(context, 0),
                ),

                // Jadwal - Digeser ke kiri 2.w
                _buildNavItem(
                  iconPath: 'assets/icons/calendaro.svg',
                  label: 'Jadwal',
                  isSelected: widget.currentIndex == 1,
                  onTap: () => _handleNavigation(context, 1),
                  offsetX: -4.w,
                ),

                // // Spacer untuk FAB
                // Expanded(child: SizedBox()),

                // Tugas - Digeser ke kanan 4.w
                _buildNavItem(
                  iconPath: 'assets/icons/task-list.svg',
                  label: 'Tugas',
                  isSelected: widget.currentIndex == 2,
                  onTap: () => _handleNavigation(context, 2),
                  offsetX: 4.w,
                ),

                // Profil
                _buildNavItem(
                  iconPath: 'assets/icons/profile-circle.svg',
                  label: 'Profil',
                  isSelected: widget.currentIndex == 3,
                  onTap: () => _handleNavigation(context, 3),
                ),
              ],
            ),
          ),
        ),

        // FAB Kiri (Aktivitas)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _isRotated ? leftPosition : 50.w - 6.w,
          bottom: kBottomNavigationBarHeight + 7.h,
          child: _buildFloatingFABWithTooltip(
            onTap: () {
              print('DEBUG: FAB Kiri di-tap - navigasi ke Aktivitas');
              context.router.push(AddAktivitasRoute());
              setState(() {
                _isRotated = false;
              });
            },
            iconPath: 'assets/icons/activity.svg',
            isVisible: _isRotated,
            tooltipText: 'Aktivitas',
          ),
        ),

        // FAB Kanan (Tugas)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: _isRotated ? rightPosition : 50.w - 6.w,
          bottom: kBottomNavigationBarHeight + 7.h,
          child: _buildFloatingFABWithTooltip(
            onTap: () {
              print('DEBUG: FAB Kanan di-tap - navigasi ke Tugas');
              context.router.push(AddTaskRoute());
              setState(() {
                _isRotated = false;
              });
            },
            iconPath: 'assets/icons/task-list.svg',
            isVisible: _isRotated,
            tooltipText: 'Tugas',
          ),
        ),

        // FAB Utama (Tengah)
        Positioned(
          left: 50.w - 6.5.w,
          bottom: kBottomNavigationBarHeight - 1.5.h,
          child: Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6.5.w),
                onTap: () {
                  setState(() {
                    _isRotated = !_isRotated;
                  });
                },
                child: Center(
                  child: AnimatedRotation(
                    turns: _isRotated ? 0.125 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _buildSvgIcon(
                      'assets/icons/plus.svg',
                      AppTheme.buttonBackgroundColor,
                      size: 4.5.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
