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

  @override
  Widget build(BuildContext context) {
    const double fabSize = 56;
    const double navBarHeight = 73;
    final double totalHeight = _isRotated ? 140 : navBarHeight;

    return Stack(
      children: [
        if (_isRotated)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
        Container(
          height: totalHeight,
          decoration: const BoxDecoration(
            color: Colors.transparent, // Ubah sesuai warna yang diinginkan
          ),
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
                child: IgnorePointer(
                  ignoring: _isRotated,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: AppTheme.lightSecondaryTextColor.withOpacity(
                            0.1,
                          ),
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
                        labelTextStyle: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          final isSelected = states.contains(
                            WidgetState.selected,
                          );
                          return GoogleFonts.plusJakartaSans(
                            fontStyle: FontStyle.normal,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.buttonBackgroundColor,
                          );
                        }),
                        iconTheme: WidgetStateProperty.resolveWith((states) {
                          final isSelected = states.contains(
                            WidgetState.selected,
                          );
                          return IconThemeData(
                            color:
                                isSelected
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
              ),

              // FAB Kiri
              Positioned(
                bottom: navBarHeight + 22,
                left:
                    MediaQuery.of(context).size.width / 2 - (fabSize / 2) - 40,
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
                          context.router.push(AddAktivitasRoute());
                          setState(() => _isRotated = false);
                        });
                      },
                      backgroundColor: AppTheme.primaryColor,
                      shape: const CircleBorder(),
                      child: _buildSvgIcon(
                        'assets/icons/activity.svg',
                        AppTheme.buttonBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ),

              // FAB Kanan
              Positioned(
                bottom: navBarHeight + 22,
                left:
                    MediaQuery.of(context).size.width / 2 - (fabSize / 2) + 46,
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
                          setState(() => _isRotated = false);
                        });
                      },
                      backgroundColor: AppTheme.primaryColor,
                      shape: const CircleBorder(),
                      child: _buildSvgIcon(
                        'assets/icons/task-list.svg',
                        AppTheme.buttonBackgroundColor,
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
                  onPressed: () => setState(() => _isRotated = !_isRotated),
                  backgroundColor: AppTheme.primaryColor,
                  shape: const CircleBorder(),
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
            ],
          ),
        ),
      ],
    );
  }
}
