import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';

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

  void _handleNavigation(BuildContext context, int index) {
    if (index == widget.currentIndex) return;

    _navigationThrottle.run(() {
      switch (index) {
        case 0:
          context.router.replace(const HomeRoute());
          break;
        case 1:
          context.router.replace(const ScheduleRoute());
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

  @override
  Widget build(BuildContext context) {
    const double fabSize = 56;
    const double totalHeight = 120; // Total tinggi widget termasuk tombol
    const double navBarHeight = 73;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: navBarHeight,
            child: Container(
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
                    return GoogleFonts.plusJakartaSans(
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color:
                          states.contains(WidgetState.selected)
                              ? AppTheme.primaryColor
                              : AppTheme.buttonBackgroundColor,
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    return IconThemeData(
                      color:
                          states.contains(WidgetState.selected)
                              ? AppTheme.primaryColor
                              : AppTheme.buttonBackgroundColor,
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: widget.currentIndex,
                  onDestinationSelected:
                      (index) => _handleNavigation(context, index),
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
                        'assets/icons/calendaro.svg',
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.buttonBackgroundColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      selectedIcon: SvgPicture.asset(
                        'assets/icons/calendaro.svg',
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'Jadwal',
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
            ),
          ),

          // FAB Kiri
          Positioned(
            bottom: navBarHeight + 22,
            left: MediaQuery.of(context).size.width / 2 - (fabSize / 2) - 40,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isRotated ? 1 : 0,
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: _isRotated ? Offset.zero : const Offset(0.5, 0.5),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: FloatingActionButton(
                  heroTag: 'leftFab',
                  mini: true,
                  elevation: 6,
                  onPressed: () {
                    _navigationThrottle.run(() {
                      context.router.push(AddScheduleRoute());
                    });
                  },
                  backgroundColor: AppTheme.primaryColor,
                  shape: const CircleBorder(),
                  child: SvgPicture.asset(
                    'assets/icons/activity.svg',
                    width: 24,
                    height: 24,
                    color: AppTheme.buttonBackgroundColor,
                  ),
                ),
              ),
            ),
          ),

          // FAB Kanan
          Positioned(
            bottom: navBarHeight + 22,
            left: MediaQuery.of(context).size.width / 2 - (fabSize / 2) + 40,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isRotated ? 1 : 0,
              curve: Curves.easeInOut,
              child: AnimatedSlide(
                offset: _isRotated ? Offset.zero : const Offset(-0.5, 0.5),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: FloatingActionButton(
                  heroTag: 'rightFab',
                  mini: true,
                  elevation: 6,
                  onPressed: () {
                    _navigationThrottle.run(() {
                      context.router.push(AddTaskRoute());
                    });
                  },
                  backgroundColor: AppTheme.primaryColor,
                  shape: const CircleBorder(),
                  child: SvgPicture.asset(
                    'assets/icons/task-list.svg',
                    width: 24,
                    height: 24,
                    color: AppTheme.buttonBackgroundColor,
                  ),
                ),
              ),
            ),
          ),

          // FAB Utama
          Positioned(
            bottom: navBarHeight - 30,
            left: MediaQuery.of(context).size.width / 2 - (fabSize / 2),
            child: FloatingActionButton(
              elevation: 6,
              onPressed: () {
                setState(() {
                  _isRotated = !_isRotated;
                });
              },
              backgroundColor: AppTheme.primaryColor,
              shape: const CircleBorder(),
              child: AnimatedRotation(
                turns: _isRotated ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 24,
                  height: 24,
                  color: AppTheme.buttonBackgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
