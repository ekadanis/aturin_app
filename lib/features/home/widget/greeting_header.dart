import 'package:aturin_app/core/services/api/profile/profile_service.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/ui/profile_page.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:auto_route/auto_route.dart';

class GreetingHeader extends StatefulWidget implements PreferredSizeWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(75);
}

class _GreetingHeaderState extends State<GreetingHeader> {
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _userFuture = _getLoggedInUser();
    });
  }

  Future<User?> _getLoggedInUser() async {
    try {
      final profileService = ProfileService();
      final user = await profileService.getBannerProfile();

      if (user != null) {
        return user;
      } else {
        debugPrint('User data tidak ditemukan dari getBannerProfile.');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting logged in user via banner profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Center(
              child: Text(
                "Gagal memuat data user",
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.lightTextColor,
                ),
              ),
            ),
          );
        }

        final user = snapshot.data!;

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
                      _loadUser();
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
                      // Jumlah tugas + aktivitas hari ini
                      Builder(
                        builder: (context) {
                          final activityCount = user.todayActivities ?? 0;
                          final taskCount = user.todayTasks ?? 0;

                          return RichText(
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
                                  text: '($activityCount)',
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
                                  text: '($taskCount)',
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
                          );
                        },
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
