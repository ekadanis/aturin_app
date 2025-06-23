import 'package:aturin_app/core/providers/global_state_service.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';

class GreetingHeader extends StatefulWidget implements PreferredSizeWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(75);
}

class _GreetingHeaderState extends State<GreetingHeader> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data load without waiting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalState = Provider.of<GlobalStateService>(context, listen: false);
      globalState.getUser(); // Load user data if not cached
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStateService>(
      builder: (context, globalState, child) {
        final user = globalState.currentUser;
        
        // Show fallback UI while data is loading for the first time
        if (user == null && globalState.isLoadingUser) {
          return AppBar(
            backgroundColor: AppTheme.lightBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 65,
            title: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  // Placeholder avatar
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    radius: 28,
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Placeholder text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 14,
                          width: 180,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTextColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show error state or default user
        if (user == null) {
          return AppBar(
            backgroundColor: AppTheme.lightBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 65,
            title: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage('assets/avatars/profile1.jpg'),
                    radius: 28,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai, User!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Hari ini: (${globalState.todayActivitiesCount}) aktivitas, (${globalState.todayTasksCount}) tugas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.lightTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Normal state with user data
        return AppBar(
          backgroundColor: AppTheme.lightBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 65,
          titleSpacing: 16,
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                // Avatar dan dot hijau dengan ukuran lebih kecil
                GestureDetector(
                  onTap: () async {
                    final result = await context.router.push(const ProfileRoute());
                    // Refresh jika ada perubahan dari ProfilePage
                    if (result != null) {
                      globalState.onUserChanged();
                    }
                  },
                  
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(user.avatar),
                        radius: 28,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 5,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.lightBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Informasi user dan task count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama pengguna
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hai, ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: user.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.lightTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Jumlah tugas + aktivitas hari ini - REAL TIME dari GlobalStateService
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hari ini: ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.lightTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '(${globalState.todayActivitiesCount})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.dangerColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' aktivitas, ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.lightTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '(${globalState.todayTasksCount})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.dangerColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' tugas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.lightTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
