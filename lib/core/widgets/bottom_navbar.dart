import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart'; 

import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/utils/debouncer.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;

  const BottomNavbar({
    super.key,
    required this.currentIndex
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final _navigationThrottle = Throttle(milliseconds: 800);

  void _handleNavigation(BuildContext context, int index) {
    if (index == widget.currentIndex) return;

    _navigationThrottle.run(() {
      switch (index) {
        case 0:
          context.router.replace(const HomeRoute());
          break;
        case 1:
          context.router.replace(const TaskListRoute());
          break;
        case 2:
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
          elevation: 10,
          labelPadding: const EdgeInsets.only(top: 0),
          backgroundColor: AppTheme.lightCardColor,
          indicatorColor: Colors.transparent,
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
              return IconThemeData(
                color: AppTheme.primaryColor,
              );
            }
            return IconThemeData(
              color: AppTheme.buttonBackgroundColor,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: widget.currentIndex,
          onDestinationSelected: (index) => _handleNavigation(context, index),
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
      ),
    );
  }
}