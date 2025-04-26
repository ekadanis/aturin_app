import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:aturin_app/features/profile/widgets/profile_card.dart';
import 'package:aturin_app/features/profile/ui/profile_edit_page.dart';
import 'package:aturin_app/features/profile/widgets/notification_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User?> _userFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _userFuture = _profileService.getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //Menggunakan PopScope agar ketika user ada di profile page dan menekan tombol back,
      //maka ia akan kembali ke halaman home page
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (_) => false
        );

        return;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        appBar: AppBar(
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
        bottomNavigationBar: const BottomNavbar(currentIndex: 2),
        body: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.lightTextColor,
                ),
              ));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text(
                'No user data found',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.lightTextColor,
                ),
              ));
            }

            User user = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: AppTheme.lightBackgroundColor,
                    padding: const EdgeInsets.all(16),
                    child: ProfileCard(
                      user: user,
                      onEdit: () => _navigateToEditPage(context, user),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Notifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTextColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  NotificationCard(
                    Title: 'Alarm',
                    Description: 'Atur Alarm kamu',
                  ),
                ],
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
