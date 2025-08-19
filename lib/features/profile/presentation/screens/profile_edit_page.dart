import 'package:aturin_app/shared/core/services/api/profile/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/data/models/user_model.dart';
import 'package:aturin_app/features/profile/presentation/widgets/profile_avatar_edit.dart';
import 'package:aturin_app/features/profile/presentation/widgets/profile_text_field.dart';
import 'package:aturin_app/features/profile/presentation/screens/avatar_selection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/features/profile/presentation/widgets/snackbar.dart';
import 'package:aturin_app/features/profile/presentation/widgets/confirm_discard_changes_dialog.dart';
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
  bool _hasChanges = false; // Track apakah ada perubahan
  bool _isSaving = false;

  late User _currentUser;

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
    _currentUser = widget.user;
    _usernameController = TextEditingController(text: widget.user.name);
    _selectedAvatar = widget.user.avatar;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    return _usernameController.text.trim() != _currentUser.name.trim() ||
        _selectedAvatar != _currentUser.avatar;
  }

  void _showAvatarSelection() async {
    // PENTING: Tutup keyboard sebelum navigasi ke halaman avatar
    FocusScope.of(context).unfocus();
    
    // Tunggu sebentar agar keyboard benar-benar tertutup
    await Future.delayed(const Duration(milliseconds: 200));
    
    final selectedAvatar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarSelectionPage(
          availableAvatars: _availableAvatars,
          selectedAvatar: _selectedAvatar,
        ),
      ),
    );

    // Reset username ke username lama jika kosong setelah kembali dari halaman avatar
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameController.text = widget.user.name;
      });
    }

    // Update avatar jika ada perubahan
    if (selectedAvatar != null && selectedAvatar != _selectedAvatar) {
      setState(() {
        _selectedAvatar = selectedAvatar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent automatic pop
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          await _onBackPressed();
        }
      },
      child: GestureDetector(
        // Tutup keyboard saat tap area kosong
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true, // Penting untuk menghindari overflow
          appBar: AppBar(
            title: Text(
              'Ubah Profil',
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
              onPressed: _onBackPressed,
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/check.svg',
                  width: 14,
                  height: 14,
                  color: const Color(0xFF131927),
                ),
                onPressed: () => _saveChanges(),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
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
                  // Tambahkan spacing ekstra untuk menghindari overflow
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges({bool shouldPop = true}) async {
    if (_isSaving) return; // Mencegah eksekusi ganda

    // Tutup keyboard saat save
    FocusScope.of(context).unfocus();

    if (_usernameController.text.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      try {
        final updatedUser = await _profileService.editProfile(
          _usernameController.text,
          _selectedAvatar,
        );

        if (updatedUser != null) {
          setState(() {
            // Update your local user state with the new, saved data.
            // This is the crucial step.
            _currentUser = updatedUser;
            _hasChanges = true;
          });

          showCustomTopSnackbar(
            context: context,
            message: 'Berhasil Memperbarui Profile',
          );

          if (shouldPop) {
            Navigator.pop(context, _hasChanges); // Return true karena ada perubahan
          }
        } else {
          showCustomTopSnackbar(
            context: context,
            message: 'Gagal memperbarui profil',
            isError: true,
          );
        }
      } catch (e) {
        showCustomTopSnackbar(
          context: context,
          message: 'Error: $e',
          isError: true,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else {
      showCustomTopSnackbar(
        context: context,
        message: 'Nama tidak boleh kosong',
        isError: true,
      );
    }
  }

  Future<void> _onBackPressed() async {
    // Tutup keyboard saat back
    FocusScope.of(context).unfocus();
    
    if (_hasUnsavedChanges()) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => const ConfirmDiscardChangesDialog(),
      );

      if (shouldLeave == true && mounted) {
        Navigator.pop(context, _hasChanges); // tetap return status _hasChanges
      }
    } else {
      Navigator.pop(context, _hasChanges);
    }
  }
}
