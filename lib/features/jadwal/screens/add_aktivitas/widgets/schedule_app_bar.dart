import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditMode;
  final VoidCallback onSave;

  const ScheduleAppBar({
    super.key,
    required this.isEditMode,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        isEditMode ? 'Edit Aktivitas' : 'Tambah Aktivitas',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: onSave,
          tooltip: isEditMode ? 'Simpan perubahan' : 'Simpan aktivitas',
        ),
      ],
    );
  }
}
