import 'package:aturin_app/core/widgets/edit_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/task_model.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/utils/debouncer.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleAlarm;
  final String currentFilter;
  final bool showCheckbox;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onViewDetails,
    required this.onToggleAlarm,
    required this.currentFilter,
    this.showCheckbox = true, // default aktif
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  // Throttle untuk mencegah multiple tap
  final _actionThrottle = Throttle(milliseconds: 500);

  // Handler yang aman untuk onToggleCompletion
  void _handleToggleCompletion() {
    _actionThrottle.run(() {
      widget.onToggleCompletion();
    });
  }

  // Handler yang aman untuk onDelete dengan konfirmasi
  void _handleDelete() {
    _actionThrottle.run(() {
      _showDeleteConfirmationDialog();
    });
  }

  void _showDeleteConfirmationDialog() {
    PanaraConfirmDialog.showAnimatedGrow(
      context,
      title: "Hapus Tugas",
      message:
          "Apakah Anda yakin ingin menghapus tugas \"${widget.task.title}\"?",
      confirmButtonText: "Hapus",
      cancelButtonText: "Batal",
      onTapCancel: () {
        Navigator.pop(context);
      },
      onTapConfirm: () {
        Navigator.pop(context);
        widget.onDelete();
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: true,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  // Handler yang aman untuk onViewDetails
  void _handleViewDetails() {
    _actionThrottle.run(() {
      widget.onViewDetails();
    });
  }

  // Handler yang aman untuk onToggleAlarm
  void _handleToggleAlarm() {
    _actionThrottle.run(() {
      widget.onToggleAlarm();
    });
  }

  @override
  void dispose() {
    _actionThrottle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah card memiliki indikator terlambat atau alarm
    final bool hasLateIndicator =
        widget.task.isCompleted &&
        widget.task.previousStatus == TaskStatus.late;
    final bool hasAlarmIndicator = widget.task.isAlarmActive;

    return Container(
      key: ValueKey(widget.task.id),
      // Memastikan overflow konten dipotong sesuai border
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Selalu menggunakan radius 12
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  if (widget.showCheckbox)
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: GestureDetector(
                        onTap: _handleToggleCompletion,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color:
                                widget.task.isCompleted
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child:
                              widget.task.isCompleted
                                  ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: AppTheme.lightCardColor,
                                  )
                                  : null,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 0),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 6,
                            children: [
                              // badge category
                              _buildBadge(
                                icon: Icons.school,
                                label: _getCategoryName(widget.task.category),
                                bgColor: const Color(0xFFCCEAFF),
                                textColor: const Color(0xFF3498DB),
                              ),

                              // badge tugas / aktivitas
                              _buildBadge(
                                icon: Icons.list,
                                label: 'Tugas',
                                bgColor: const Color(0xFFDFEAFF),
                                textColor: const Color(0xFF5263F3),
                              ),

                              // badge alarm
                              _buildBadge(
                                icon: Icons.timer,
                                label: '',
                                bgColor: const Color(0xFFDFEAFF),
                                textColor: const Color(0xFF5263F3),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.task.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF131927),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_filled,
                                size: 12,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Estimasi: ${widget.task.estimatedDuration.inHours}:${(widget.task.estimatedDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // badge status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(
                              widget.task,
                              widget.currentFilter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getBadgeText(widget.task, widget.currentFilter),
                            style: TextStyle(
                              color: _getBadgeTextColor(
                                widget.task,
                                widget.currentFilter,
                              ),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder:
                              (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(16),
                                child: EditPopup(
                                  currentIndex: widget.task.id!,
                                  task: widget.task,
                                ),
                              ),
                        );
                      }
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Opsi'),
                          ),
                        ],
                  ),
                ],
              ),
              if (hasLateIndicator)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDECEC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Diselesaikan terlambat',
                      style: TextStyle(
                        color: Color(0xFFD93E39),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF5263F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Stack(
      //       children: [
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             //strip biru
      //             Container(
      //               width: 6,
      //               height: 120,
      //               decoration: const BoxDecoration(
      //                 color: Color(0xFF3A5AFE), // warna biru
      //                 borderRadius: BorderRadius.only(
      //                   topLeft: Radius.circular(12),
      //                   bottomLeft: Radius.circular(12),
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(width: 12),

      //             Expanded(
      //               child: Padding(
      //                 padding: const EdgeInsets.all(12.0),
      //                 child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Row(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //
      //                       // Informasi tugas
      //                       Expanded(
      //                         child: Column(
      //                           crossAxisAlignment: CrossAxisAlignment.start,
      //                           children: [
      //                             // Kategori
      //                             Row(
      //                               children: [
      //                                 SvgPicture.asset(
      //                                   _getCategoryIconPath(
      //                                     widget.task.category,
      //                                   ),
      //                                   width:
      //                                       16, // Ukuran ikon kategori diperkecil
      //                                   height:
      //                                       16, // Untuk proporsi yang lebih baik
      //                                 ),

      //                                 const SizedBox(
      //                                   width: 6,
      //                                 ), // Jarak ditambah
      //                                 Text(
      //                                   _getCategoryName(widget.task.category),
      //                                   style: GoogleFonts.plusJakartaSans(
      //                                     // Menggunakan font yang konsisten
      //                                     fontSize:
      //                                         11, // Ukuran font sedikit dikurangi
      //                                     fontWeight:
      //                                         FontWeight
      //                                             .w500, // Ketebalan sedang
      //                                     color:
      //                                         AppTheme.lightSecondaryTextColor,
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                             const SizedBox(height: 6), // Jarak ditambah
      //                             // Judul tugas
      //                             Text(
      //                               widget.task.title,
      //                               style: GoogleFonts.plusJakartaSans(
      //                                 fontSize: 14, // Ukuran font diperbesar
      //                                 fontWeight:
      //                                     FontWeight
      //                                         .w700, // Lebih tebal dari sebelumnya
      //                                 color:
      //                                     AppTheme
      //                                         .lightTextColor, // Warna teks utama
      //                               ),
      //                             ),
      //                             const SizedBox(height: 6), // Jarak ditambah
      //                             // Estimasi waktu
      //                             Row(
      //                               children: [
      //                                 const Icon(
      //                                   Icons.access_time_filled,
      //                                   size: 14,
      //                                 ),
      //                                 const SizedBox(width: 4),
      //                                 Text(
      //                                   'Estimasi: ${widget.task.estimatedDuration.inHours}:${(widget.task.estimatedDuration.inMinutes % 60).toString().padLeft(2, '0')}',
      //                                   style: const TextStyle(
      //                                     fontSize: 12,
      //                                     color: Colors.black54,
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                       
      //                       EditPopup(currentIndex: widget.task.id!, task: widget.task)
      //                       // PopupMenuButton<String>(
      //                       //   icon: const Icon(Icons.more_vert, size: 20),
      //                       //   onSelected: (value) {
      //                       //     if (value == 'edit') {
      //                       //       showDialog(
      //                       //         context: context,
      //                       //         builder:
      //                       //             (_) => Dialog(
      //                       //               backgroundColor: Colors.transparent,
      //                       //               insetPadding: const EdgeInsets.all(
      //                       //                 16,
      //                       //               ),
      //                       //               child: EditPopup(
      //                       //                 currentIndex: widget.task.id!,
      //                       //                 task: widget.task,
      //                       //               ),
      //                       //             ),
      //                       //       );
      //                       //     }
      //                       //   },
      //                       //   itemBuilder:
      //                       //       (context) => [
      //                       //         const PopupMenuItem<String>(
      //                       //           value: 'edit',
      //                       //           child: Text('Opsi'),
      //                       //         ),
      //                       //       ],
      //                       // ),
      //                     ],
      //                   ),
      //                 ],
      //               )
      //               )
      //               ,
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),

      //     Container(padding: const EdgeInsets.all(16.0)),

      //     // Alarm indicator if active (only shown for non-completed tasks)
      //     if (widget.task.isAlarmActive && !widget.task.isCompleted)
      //       ClipRRect(
      //         // Clip the corners to match the parent container's border radius
      //         borderRadius: const BorderRadius.only(
      //           bottomLeft: Radius.circular(12),
      //           bottomRight: Radius.circular(12),
      //         ),
      //         child: Container(
      //           height: 24,
      //           padding: const EdgeInsets.symmetric(horizontal: 16),
      //           decoration: const BoxDecoration(
      //             border: Border(
      //               top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
      //             ),
      //           ),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.end,
      //             children: const [
      //               Icon(
      //                 Icons.alarm,
      //                 size: 12,
      //                 color: AppTheme.alarmActiveColor,
      //               ),
      //               SizedBox(width: 4),
      //               Text(
      //                 'Alarm aktif',
      //                 style: TextStyle(
      //                   fontSize: 12,
      //                   color: AppTheme.alarmActiveColor,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),

      //     // "Diselesaikan terlambat" indicator if applicable
      //     if (widget.task.isCompleted &&
      //         widget.task.previousStatus == TaskStatus.late)
      //       ClipRRect(
      //         // Clip the corners to match the parent container's border radius
      //         borderRadius: const BorderRadius.only(
      //           bottomLeft: Radius.circular(12),
      //           bottomRight: Radius.circular(12),
      //         ),
      //         child: Container(
      //           width: double.infinity,
      //           height: 24,
      //           padding: const EdgeInsets.symmetric(horizontal: 16),
      //           decoration: const BoxDecoration(
      //             color: Color(0xFFFFF0F0),
      //             border: Border(
      //               top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
      //             ),
      //           ),
      //           child: const Row(
      //             mainAxisAlignment: MainAxisAlignment.end,
      //             children: [
      //               Text(
      //                 '* Diselesaikan terlambat',
      //                 style: TextStyle(
      //                   fontSize: 12,
      //                   color: Colors.red,
      //                   fontStyle: FontStyle.italic,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //   ],
      // ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: textColor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getCategoryIconPath(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.name == category.toLowerCase(),
      );
      switch (taskCategory) {
        case TaskCategory.akademik:
          return 'assets/images/akademik.svg';
        case TaskCategory.hiburan:
          return 'assets/images/hiburan.svg';
        case TaskCategory.pekerjaan:
          return 'assets/images/pekerjaan.svg';
        case TaskCategory.olahraga:
          return 'assets/images/olahraga.svg';
        case TaskCategory.sosial:
          return 'assets/images/sosial.svg';
        case TaskCategory.spiritual:
          return 'assets/images/spiritual.svg';
        case TaskCategory.pribadi:
          return 'assets/images/pribadi.svg';
        case TaskCategory.istirahat:
          return 'assets/images/istirahat.svg';
      }
    } catch (_) {
      return 'assets/images/akademik.svg';
    }
  }

  String _getCategoryName(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.$category',
      );

      switch (taskCategory) {
        case TaskCategory.akademik:
          return 'Akademik';
        case TaskCategory.hiburan:
          return 'Hiburan';
        case TaskCategory.pekerjaan:
          return 'Pekerjaan';
        case TaskCategory.olahraga:
          return 'Olahraga';
        case TaskCategory.sosial:
          return 'Sosial';
        case TaskCategory.spiritual:
          return 'Spiritual';
        case TaskCategory.pribadi:
          return 'Pribadi';
        case TaskCategory.istirahat:
          return 'Istirahat';
      }
    } catch (_) {
      return category;
    }
  }

  String _getStatusName(TaskStatus status, {Task? task}) {
    switch (status) {
      case TaskStatus.completed:
        return 'Selesai';
      case TaskStatus.late:
        return 'Terlambat';
      case TaskStatus.today:
        return 'Hari Ini';
      case TaskStatus.tomorrow:
        return 'Besok';
      case TaskStatus.upcoming:
        if (task != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final deadlineDay = DateTime(
            task.deadline.year,
            task.deadline.month,
            task.deadline.day,
          );
          final daysRemaining = deadlineDay.difference(today).inDays;
          return '$daysRemaining hari lagi';
        }
        return 'Mendatang';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFFE3F2E9);
      case TaskStatus.late:
        return const Color(0xFFE4E4E7);
      case TaskStatus.today:
        return const Color(0xFFE6F4FF);
      case TaskStatus.tomorrow:
        return const Color(0xFFFFE5B0);
      case TaskStatus.upcoming:
        return const Color(0xFFFFE5B0);
    }
  }

  Color _getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF4CAF50);
      case TaskStatus.late:
        return const Color(0xFF999999);
      case TaskStatus.today:
        return const Color(0xFF0077CC);
      case TaskStatus.tomorrow:
        return const Color(0xFFE89B00);
      case TaskStatus.upcoming:
        return const Color(0xFFE89B00);
    }
  }

  String _getBadgeText(Task task, String currentFilter) {
    if (task.isCompleted) {
      return 'Selesai';
    }
    return _getStatusName(task.status, task: task);
  }

  Color _getBadgeColor(Task task, String currentFilter) {
    if (task.isCompleted) {
      return AppTheme.completedColor;
    }
    return _getStatusColor(task.status);
  }

  Color _getBadgeTextColor(Task task, String currentFilter) {
    if (task.isCompleted) {
      return AppTheme.completedTextColor;
    }
    return _getStatusTextColor(task.status);
  }
}
