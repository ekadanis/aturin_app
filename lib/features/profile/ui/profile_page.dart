import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:aturin_app/features/profile/widgets/profile_card.dart';
import 'package:aturin_app/features/profile/ui/profile_edit_page.dart';
import 'package:aturin_app/features/profile/widgets/notification_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF131927),
              ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          }

          User user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
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
