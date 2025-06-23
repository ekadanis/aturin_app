import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aturin_app/core/services/api/profile/profile_service.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class EditUsernameDialog extends StatefulWidget {
  final String currentUsername;
  final int userId;
  final void Function(String newUsername) onUsernameUpdated;
  final ProfileService profileService;
  final String currentAvatar; // Menambahkan properti avatar

  const EditUsernameDialog({
    super.key,
    required this.currentUsername,
    required this.userId,
    required this.onUsernameUpdated,
    required this.profileService,
    required this.currentAvatar, // Membutuhkan avatar saat inisialisasi
  });

  @override
  State<EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<EditUsernameDialog> {
  late TextEditingController _controller;
  bool _isError = false;
  String _errorMessage = '';
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
    _characterCount = widget.currentUsername.length;
    _controller.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCharCount);
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final newUsername = _controller.text.trim();
    if (newUsername.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Nama harus diisi.';
      });
    } else if (newUsername.length > 20) {
      setState(() {
        _isError = true;
        _errorMessage = 'Nama maksimal 20 karakter.';
      });
    } else {
      try {
        // Gunakan editProfile dari API ProfileService
        final updatedUser = await widget.profileService.editProfile(
          newUsername,
          widget.currentAvatar, // Menggunakan avatar yang ada
        );

        if (updatedUser != null) {
          // Call the callback with the new username
          widget.onUsernameUpdated(newUsername);

          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _isError = true;
            _errorMessage = 'Gagal mengubah nama. Coba lagi.';
          });
        }
      } catch (e) {
        setState(() {
          _isError = true;
          _errorMessage = 'Gagal mengubah nama. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightBackgroundColor,
      insetPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: AppTheme.lightTextColor),
              maxLength: 20,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                hintText: 'Nama',
                filled: true,
                fillColor: Colors.white,
                counterText: '', // Menyembunyikan counter default
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isError ? AppTheme.lightErrorColor : AppTheme.lightDividerColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isError ? AppTheme.lightErrorColor : AppTheme.lightDividerColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isError ? AppTheme.lightErrorColor : AppTheme.primaryColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            // Menambahkan counter custom
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '$_characterCount/20',
                  style: TextStyle(
                    color: AppTheme.lightSecondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (_isError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: AppTheme.lightErrorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                      foregroundColor: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
