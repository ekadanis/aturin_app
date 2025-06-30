import 'package:aturin_app/core/services/api/auth/auth_service.dart';
import 'package:aturin_app/core/services/api/profile/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user_model.dart';
import 'package:aturin_app/features/profile/widgets/profile_card.dart';
import 'package:aturin_app/features/profile/ui/profile_edit_page.dart';
import 'package:aturin_app/features/profile/widgets/pengaturan_card.dart';
import 'package:aturin_app/features/profile/widgets/logout_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/profile/widgets/confirm_exit_dialog.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
  }

  void _loadUser() {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final newUserFuture = profileService.me();
    setState(() {
      _userFuture = newUserFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tinggi bottom navigation untuk padding scroll
    final bottomNavHeight = kBottomNavigationBarHeight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (_) => false,
        );
        return;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        extendBody: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profil',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTextColor,
            ),
          ),
          elevation: 0,
          backgroundColor: AppTheme.lightBackgroundColor,
          foregroundColor: AppTheme.lightTextColor,
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 3),
        body: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: {snapshot.error}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.lightTextColor,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  'Tidak ada data pengguna yang ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.lightTextColor,
                  ),
                ),
              );
            }

            User user = snapshot.data!;

            return SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bisa tambahkan header image/profile di sini jika ingin konsisten dengan HomePage
                    SizedBox(height: 2),
                    ProfileCard(
                      user: user,
                      onEdit: () => _navigateToEditPage(context, user),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pengaturan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PengaturanCard(
                      title: 'Alarm',
                      description: 'Atur Alarm kamu',
                    ),
                    const SizedBox(height: 8),
                    LogoutButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => const ConfirmExitDialog(),
                        );
                        if (confirm == true) {
                          final authService = AuthService();
                          final result = await authService.logout();
                          if (result.isSuccess) {
                            if (context.mounted) {
                              context.router.replaceAll([const LoginRoute()]);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.message.isNotEmpty ? result.message : 'Logout gagal'),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    // Spacer agar konten tidak ketutupan bottom nav
                    const Spacer(),
                    SizedBox(height: bottomNavHeight + 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _navigateToEditPage(BuildContext context, User user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ProfileEditPage(user: user)),
    );
    if (result == true) {
      _loadUser();
    }
  }
}
