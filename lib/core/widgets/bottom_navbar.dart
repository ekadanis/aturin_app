import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        elevation: 10,
        labelPadding: const EdgeInsets.only(top: 0),
        backgroundColor: Colors.white,
        indicatorColor: WidgetStateColor.transparent,
        overlayColor: WidgetStateColor.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontStyle: FontStyle.normal,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontStyle: FontStyle.normal,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.buttonBackgroundColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppTheme.primaryColor,
            );
          }
          return const IconThemeData(
            color: AppTheme.buttonBackgroundColor,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/home-simple.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.buttonBackgroundColor,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/home-simple.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/task-list.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.buttonBackgroundColor,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/task-list.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/profile-circle.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.buttonBackgroundColor,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/profile-circle.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}