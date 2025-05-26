// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:aturin_app/core/widgets/schedule_card_widget.dart';
// import 'package:aturin_app/features/schedule/model/schedule.dart';
// import 'package:aturin_app/features/task/model/task.dart';

// class ScheduleListWidget extends StatelessWidget {
//   final List<ScheduleModel> schedules;
//   final String selectedCategory;
//   final Function(ScheduleModel) onScheduleTap;
//   final Function(ScheduleModel) onScheduleMenuTap;

//   const ScheduleListWidget({
//     super.key,
//     required this.schedules,
//     required this.selectedCategory,
//     required this.onScheduleTap,
//     required this.onScheduleMenuTap,
//   });

//   static const List<String> _monthNames = [
//     'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
//     'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
//   ];

//   static const List<String> _dayNames = [
//     'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final filteredSchedules = _getFilteredSchedules();
//     final groupedSchedules = _groupSchedulesByDate(filteredSchedules);

//     return ListView.builder(
//       padding: const EdgeInsets.only(top: 16),
//       physics: const BouncingScrollPhysics(),
//       itemCount: groupedSchedules.length,
//       itemBuilder: (context, index) {
//         final entry = groupedSchedules.entries.elementAt(index);
//         final date = entry.key;
//         final daySchedules = entry.value;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Text(
//                 _formatDateHeader(date),
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF5263F3),
//                 ),
//               ),
//             ),
//             ...daySchedules.map(
//               (schedule) => ScheduleCardWidget(
//                 schedule: schedule,
//                 onTap: () => onScheduleTap(schedule),
//                 onMenuTap: () => onScheduleMenuTap(schedule),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         );
//       },
//     );
//   }

//   List<ScheduleModel> _getFilteredSchedules() {
//     if (selectedCategory == 'Semua') {
//       return schedules;
//     }

//     final categoryEnum = _getCategoryEnum(selectedCategory);
//     return schedules
//         .where((schedule) => schedule.activityCategory == categoryEnum)
//         .toList();
//   }

//   TaskCategory _getCategoryEnum(String categoryName) {
//     switch (categoryName) {
//       case 'Akademik':
//         return TaskCategory.akademik;
//       case 'Hiburan':
//         return TaskCategory.hiburan;
//       case 'Pekerjaan':
//         return TaskCategory.pekerjaan;
//       case 'Olahraga':
//         return TaskCategory.olahraga;
//       case 'Sosial':
//         return TaskCategory.sosial;
//       case 'Spiritual':
//         return TaskCategory.spiritual;
//       case 'Pribadi':
//         return TaskCategory.pribadi;
//       case 'Istirahat':
//         return TaskCategory.istirahat;
//       default:
//         return TaskCategory.akademik;
//     }
//   }

//   Map<DateTime, List<ScheduleModel>> _groupSchedulesByDate(
//     List<ScheduleModel> schedules,
//   ) {
//     Map<DateTime, List<ScheduleModel>> grouped = {};

//     for (final schedule in schedules) {
//       final dateKey = DateTime(
//         schedule.activityDate.year,
//         schedule.activityDate.month,
//         schedule.activityDate.day,
//       );

//       if (!grouped.containsKey(dateKey)) {
//         grouped[dateKey] = [];
//       }
//       grouped[dateKey]!.add(schedule);
//     }

//     final sortedEntries =
//         grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

//     return Map.fromEntries(sortedEntries);
//   }

//   String _formatDateHeader(DateTime date) {
//     final dayName = _dayNames[date.weekday - 1];
//     final monthName = _monthNames[date.month - 1];

//     if (isSameDay(date, DateTime.now())) {
//       return 'Hari ini\n$dayName, ${date.day} $monthName ${date.year}';
//     } else {
//       return '$dayName, ${date.day} $monthName ${date.year}';
//     }
//   }
// }