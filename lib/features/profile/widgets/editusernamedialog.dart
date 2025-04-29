import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/profile/services/profile_service.dart';

class EditUsernameDialog extends StatefulWidget {
  final String currentUsername;
  final int userId;
  final void Function(String newUsername) onUsernameUpdated;

  const EditUsernameDialog({
    super.key,
    required this.currentUsername,
    required this.userId,
    required this.onUsernameUpdated,
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
        // Get ProfileService from Provider
        final profileService = Provider.of<ProfileService>(context, listen: false);
        await profileService.changeUsername(widget.userId, newUsername);
        
        // Call the callback with the new username
        widget.onUsernameUpdated(newUsername);
        
        if (mounted) {
          Navigator.pop(context);
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
      backgroundColor: const Color(0xFFF9FAFB),
      insetPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Color(0xFF131927)),
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
                    color: _isError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EA),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EA),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isError ? const Color(0xFFEF4444) : const Color(0xFFE5E7EA),
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
                  style: const TextStyle(
                    color: Color(0xFF71717A),
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
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
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
                      side: const BorderSide(
                        color: Color(0xFF5263F3),
                        width: 1.5,
                      ),
                      foregroundColor: const Color(0xFF5263F3),
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
                      backgroundColor: const Color(0xFF5263F3),
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
