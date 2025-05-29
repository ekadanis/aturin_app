import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(task.status);
    final statusLabel = getStatusLabel(task.status);
    final category = parseTaskCategory(task.category);
    final categoryIcon = getCategoryIcon(category);
    final categoryLabel = getCategoryLabel(category);

    // Format deadline untuk menampilkan waktu saja (HH:mm)
    final timeFormat = DateFormat('HH:mm');
    final deadlineText = timeFormat.format(task.deadline);

    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppTheme.lightDividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT SIDE (info tugas)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kategori + Icon
                      Row(
                        children: [
                          SvgPicture.asset(categoryIcon, width: 16, height: 16),
                          const SizedBox(width: 4),
                          Text(
                            categoryLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.lightSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Judul tugas
                      Text(
                        task.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            size: 12, // Ukuran ikon dikurangi
                            color:
                                task.status == TaskStatus.upcoming
                                    ? AppTheme.dangerColor
                                    : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deadlineText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, // Font size dikurangi
                              color:
                                  task.status == TaskStatus.upcoming
                                      ? AppTheme.dangerColor
                                      : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // RIGHT SIDE (Status badge)
                Container(
                  alignment: Alignment.center, // pastikan ini ada
                  width: 80,
                  height: null, // biarkan tinggi otomatis mengikuti isi
                  constraints: const BoxConstraints(
                    minHeight: 32,
                  ), // tinggi minimal tetap 32
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ), // beri ruang untuk teks
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    textAlign: TextAlign.center, // teks di tengah
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Indikator tambahan (alarm atau terlambat) dengan ukuran yang lebih kecil
          if (task.isAlarmActive)
            _buildIndicator(
              AppTheme.alarmActiveColor,
              Icons.alarm,
              'Alarm aktif',
              isLateCompletion: false,
            ),

          // "Diselesaikan terlambat" indicator if applicable
          if (task.status == TaskStatus.late)
            _buildIndicator(
              AppTheme.lateTextColor,
              null,
              '* Diselesaikan terlambat',
              isLateCompletion: true,
            ),
        ],
      ),
    );
  }

  TaskCategory parseTaskCategory(String name) {
  return TaskCategory.values.firstWhere(
    (e) => e.name.toLowerCase() == name.toLowerCase(),
    orElse: () => TaskCategory.akademik, // fallback default
  );
}

  // Helper method untuk membuat indikator (alarm atau terlambat)
  Widget _buildIndicator(
    Color textColor,
    IconData? icon,
    String text, {
    required bool isLateCompletion,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        height: 20, // Tinggi indikator dikurangi
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isLateCompletion ? const Color(0xFFFFF0F0) : null,
          border: const Border(
            top: BorderSide(color: AppTheme.lightDividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, // Font size dikurangi
                color: textColor,
                fontStyle:
                    isLateCompletion ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF4CAF50); // Hijau
      case TaskStatus.upcoming:
        return const Color(0xFF9E9E9E); // Abu
      case TaskStatus.late:
        return const Color(0xFFFF6B6B); // Merah
      case TaskStatus.today:
        return const Color(0xFF2196F3); // Biru
      case TaskStatus.tomorrow:
        return const Color(0xFFFFC107); // Kuning
    }
  }

  static String getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return 'Selesai';
      case TaskStatus.upcoming:
        return 'Mendatang';
      case TaskStatus.late:
        return 'Terlambat';
      case TaskStatus.today:
        return 'Hari Ini';
      case TaskStatus.tomorrow:
        return 'Besok';
    }
  }

  static String getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.akademik:
        return 'assets/images/akademik.svg';
      case TaskCategory.hiburan:
        return 'assets/images/hiburan.svg';
      case TaskCategory.istirahat:
        return 'assets/images/istirahat.svg';
      case TaskCategory.olahraga:
        return 'assets/images/olahraga.svg';
      case TaskCategory.pekerjaan:
        return 'assets/images/pekerjaan.svg';
      case TaskCategory.pribadi:
        return 'assets/images/pribadi.svg';
      case TaskCategory.sosial:
        return 'assets/images/sosial.svg';
      case TaskCategory.spiritual:
        return 'assets/images/spiritual.svg';
    }
  }

  String getCategoryLabel(TaskCategory category) {
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
