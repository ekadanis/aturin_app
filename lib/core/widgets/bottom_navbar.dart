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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        indicatorColor: const Color.fromARGB(0, 255, 255, 255),
        overlayColor: WidgetStateColor.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontStyle: FontStyle.normal,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color.fromARGB(255, 82, 99, 243),
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontStyle: FontStyle.normal,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: const Color.fromARGB(255, 198, 214, 255),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color.fromARGB(255, 82, 99, 243),
            );
          }
          return const IconThemeData(
            color: Color.fromARGB(255, 198, 214, 255),
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
                Color.fromARGB(255, 198, 214, 255),
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/home-simple.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 82, 99, 243),
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
                Color.fromARGB(255, 198, 214, 255),
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/task-list.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 82, 99, 243),
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
                Color.fromARGB(255, 198, 214, 255),
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/profile-circle.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 82, 99, 243),
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