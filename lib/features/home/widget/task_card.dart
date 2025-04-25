import 'package:aturin_app/features/home/models/task_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(task.status);
    final statusLabel = getStatusLabel(task.status);
    final categoryIcon = getCategoryIcon(task.category);
    final categoryLabel = getCategoryLabel(task.category);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20), // Padding yang lebih besar
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: AppTheme.lightDividerColor),
              borderRadius: BorderRadius.circular(12), // Border radius yang lebih besar
            ),
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Mengubah dari start menjadi center
            children: [
              // LEFT SIDE (info tugas)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori + Icon
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: SvgPicture.asset(categoryIcon, width: 22), // Icon kategori yang lebih besar
                        ),
                        const SizedBox(width: 6),
                        Text(
                          categoryLabel, //kategori
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.lightSecondaryTextColor,
                            fontSize: 14, // Font kategori yang lebih besar
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Space yang lebih besar
                    Text(
                      task.title, //judul
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, // Font judul yang lebih besar
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 10), // Space yang lebih besar
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 20, // Icon jam yang lebih besar
                          color: task.status == TaskStatus.terlambat
                                ? AppTheme.dangerColor
                                : const Color(0xFF1A1B4C),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.timeRange, //waktu
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, // Font waktu yang lebih besar
                            fontWeight: FontWeight.w600, // Lebih bold
                            color: task.status == TaskStatus.terlambat
                                ? AppTheme.dangerColor
                                : const Color(0xFF1A1B4C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // RIGHT SIDE (Status badge)
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // Memastikan badge di tengah secara vertikal
                children: [
                  Container(
                    width: 90,
                    height: 32,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      statusLabel, //status
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, // Font status yang lebih besar
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai:
        return const Color(0xFF3DA755); // Green
      case TaskStatus.terlambat:
        return const Color(0xFFD34141); // Red
      case TaskStatus.besok:
        return const Color(0xFFE6A73C); // Yellow
    }
  }

  static String getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai:
        return 'Selesai';
      case TaskStatus.terlambat:
        return 'Terlambat';
      case TaskStatus.besok:
        return 'Besok';
    }
  }

  static String getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.akademik:
        return 'assets/icons/graduation-cap.svg';
      case TaskCategory.hiburan:
        return 'assets/icons/gamepad.svg';
      case TaskCategory.istirahat:
        return 'assets/icons/half-moon.svg';
      case TaskCategory.olahraga:
        return 'assets/icons/gym.svg';
      case TaskCategory.pekerjaan:
        return 'assets/icons/handbag.svg';
      case TaskCategory.pribadi:
        return 'assets/icons/user-square.svg';
      case TaskCategory.sosial:
        return 'assets/icons/community.svg';
      case TaskCategory.spiritual:
        return 'assets/icons/pray.svg';
    }
  }

  static String getCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.akademik:
        return 'Akademik';
      case TaskCategory.hiburan:
        return 'Hiburan';
      case TaskCategory.istirahat:
        return 'Istirahat';
      case TaskCategory.olahraga:
        return 'Olahraga';
      case TaskCategory.pekerjaan:
        return 'Pekerjaan';
      case TaskCategory.pribadi:
        return 'Pribadi';
      case TaskCategory.sosial:
        return 'Sosial';
      case TaskCategory.spiritual:
        return 'Spiritual';
    }
  }
}
