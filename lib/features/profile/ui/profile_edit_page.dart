import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';
import 'package:aturin_app/features/profile/widgets/profile_avatar_edit.dart';
import 'package:aturin_app/features/profile/widgets/profile_text_field.dart';
import 'package:aturin_app/features/profile/ui/avatar_selection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/features/profile/widgets/snackbar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/features/profile/widgets/confirm_exit_dialog.dart';

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

  void _showAvatarSelection() async {
    final selectedAvatar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AvatarSelectionPage(
              availableAvatars: _availableAvatars,
              selectedAvatar: _selectedAvatar,
            ),
      ),
    );

    // Reset username ke username lama jika kosong setelah kembali dari halaman avatar
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameController.text = widget.user.username;
      });
    }

    // Update avatar jika ada perubahan
    if (selectedAvatar != null && selectedAvatar != _selectedAvatar) {
      setState(() {
        _selectedAvatar = selectedAvatar;
      });

      await _saveChanges(
        shouldPop: false,
      ); // Jangan pop halaman setelah save avatar
    }
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
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 16,
            height: 16,
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/log-out.svg',
              width: 28,
              height: 28,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmExitDialog(),
              );

              if (confirm == true) {
                Navigator.pop(context, true);
              }
            },
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
              editable: true,
              controller: _usernameController,
              onSubmitted: () => _saveChanges(shouldPop: false),
              maxChar: 20,
              onEditPressed: () {},
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

  Future<void> _saveChanges({bool shouldPop = true}) async {
    if (_usernameController.text.isNotEmpty) {
      try {
        if (_usernameController.text != widget.user.username) {
          await _profileService.changeUsername(
            widget.user.id!,
            _usernameController.text,
          );
        }

        if (_selectedAvatar != widget.user.avatar) {
          await _profileService.changeAvatar(widget.user.id!, _selectedAvatar);
        }

        showCustomTopSnackbar(
          context: context,
          message: 'Berhasil Mengedit Profile',
        );

        if (shouldPop) {
          Navigator.pop(context, true); // hanya pop kalau flag true
        }
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
}
