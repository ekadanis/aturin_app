import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:aturin_app/features/profile/widgets/profile_avatar_edit.dart';
import 'package:aturin_app/features/profile/widgets/profile_text_field.dart';
import 'package:aturin_app/features/profile/widgets/avatar_selection_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/features/profile/widgets/editusernamedialog.dart';
import 'package:aturin_app/features/profile/widgets/snackbar.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class ProfileEditPage extends StatefulWidget {
  final User user;

  const ProfileEditPage({super.key, required this.user});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _usernameController;
  late String _selectedAvatar;
  final ProfileService _profileService = ProfileService();

  final List<String> _availableAvatars = [
    'assets/avatars/profile1.jpg',
    'assets/avatars/profile2.jpg',
    'assets/avatars/profile3.jpg',
    'assets/avatars/profile4.jpg',
    'assets/avatars/profile5.jpg',
    'assets/avatars/profile6.jpg',
    'assets/avatars/profile7.jpg',
    'assets/avatars/profile8.jpg',
    'assets/avatars/profile9.jpg',
    'assets/avatars/profile10.jpg',
    'assets/avatars/profile11.jpg',
    'assets/avatars/profile12.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _selectedAvatar = widget.user.avatar;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _showAvatarSelection() {
    showDialog(
      context: context,
      builder: (context) {
        return AvatarSelectionDialog(
          availableAvatars: _availableAvatars,
          selectedAvatar: _selectedAvatar,
          onAvatarSelected: (avatar) {
            setState(() {
              _selectedAvatar = avatar;
            });
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF131927),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 16,
            height: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/check.svg',
              width: 14,
              height: 14,
              color: const Color(0xFF131927),
            ),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProfileAvatar(
              avatarPath: _selectedAvatar,
              onEditPressed: _showAvatarSelection,
            ),
            const SizedBox(height: 20),
            ProfileTextField(
              label: 'Nama',
              value: _usernameController.text,
              editable: true,
              onEditPressed: () {
                _showEditDialog(context, widget.user.id!);
              },
            ),
            const SizedBox(height: 20),
            ProfileTextField(
              label: 'Email',
              value: widget.user.email,
              editable: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_usernameController.text.isNotEmpty) {
      try {
        if (_usernameController.text != widget.user.username) {
          await _profileService.changeUsername(widget.user.id!, _usernameController.text);
        }

        if (_selectedAvatar != widget.user.avatar) {
          await _profileService.changeAvatar(widget.user.id!, _selectedAvatar);
        }

        showCustomTopSnackbar(
          context: context,
          message: 'Berhasil Mengedit Profile',
        );

        Navigator.pop(context, true);
      } catch (e) {
        showCustomTopSnackbar(
          context: context,
          message: 'Error: $e',
          isError: true,
        );
      }
    } else {
      showCustomTopSnackbar(
        context: context,
        message: 'Username tidak boleh kosong',
        isError: true,
      );
    }
  }

  void _showEditDialog(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (context) => EditUsernameDialog(
        currentUsername: _usernameController.text,
        userId: userId,
        onUsernameUpdated: (newUsername) {
          setState(() {
            _usernameController.text = newUsername;
          });
        },
      ),
    );
  }
}
