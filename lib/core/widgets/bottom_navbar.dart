import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:ui';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/utils/debouncer.dart';

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

  Widget _buildSvgIcon(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      height: 24,
      width: 24,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // FAB
          Container(
            width: 60,
            height: 60,
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
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white.withOpacity(0.3),
                onTap: isVisible ? onTap : null,
                child: Center(
                  child: _buildSvgIcon(
                    iconPath,
                    AppTheme.buttonBackgroundColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Stack(
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
            height: kBottomNavigationBarHeight + 16,
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
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                elevation: 0,
                labelPadding: const EdgeInsets.only(top: 0),
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return GoogleFonts.plusJakartaSans(
                    fontStyle: FontStyle.normal,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.buttonBackgroundColor,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.buttonBackgroundColor,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: widget.currentIndex,
                onDestinationSelected: (index) => _handleNavigation(context, index),
                destinations: [
                  NavigationDestination(
                    icon: _buildSvgIcon(
                      'assets/icons/home-simple.svg',
                      AppTheme.buttonBackgroundColor,
                    ),
                    selectedIcon: _buildSvgIcon(
                      'assets/icons/home-simple.svg',
                      AppTheme.primaryColor,
                    ),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: _buildSvgIcon(
                      'assets/icons/calendaro.svg',
                      AppTheme.buttonBackgroundColor,
                    ),
                    selectedIcon: _buildSvgIcon(
                      'assets/icons/calendaro.svg',
                      AppTheme.primaryColor,
                    ),
                    label: 'Jadwal',
                  ),
                  NavigationDestination(
                    icon: _buildSvgIcon(
                      'assets/icons/task-list.svg',
                      AppTheme.buttonBackgroundColor,
                    ),
                    selectedIcon: _buildSvgIcon(
                      'assets/icons/task-list.svg',
                      AppTheme.primaryColor,
                    ),
                    label: 'Tugas',
                  ),
                  NavigationDestination(
                    icon: _buildSvgIcon(
                      'assets/icons/profile-circle.svg',
                      AppTheme.buttonBackgroundColor,
                    ),
                    selectedIcon: _buildSvgIcon(
                      'assets/icons/profile-circle.svg',
                      AppTheme.primaryColor,
                    ),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // FAB Kiri (Aktivitas) - Benar-benar melayang di luar navbar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _isRotated ? screenWidth * 0.25 - 2 : screenWidth * 0.5 - 2,
          bottom: kBottomNavigationBarHeight + 50, // Di atas navbar
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
        
        // FAB Kanan (Tugas) - Benar-benar melayang di luar navbar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: _isRotated ? screenWidth * 0.25 - 2 : screenWidth * 0.5 - 2,
          bottom: kBottomNavigationBarHeight + 50,
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
        
        // FAB Utama (Tengah) - Overlap dengan navbar
        Positioned(
          left: screenWidth * 0.5 - 35,
          bottom: kBottomNavigationBarHeight - 16,
          child: Container(
            width: 70,
            height: 70,
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
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(35),
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}