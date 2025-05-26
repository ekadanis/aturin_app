// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:aturin_app/core/widgets/categories.dart';
// import 'package:aturin_app/features/schedule/model/schedule.dart';
// import 'package:aturin_app/features/task/model/task.dart';

// class ScheduleCardWidget extends StatelessWidget {
//   final ScheduleModel schedule;
//   final VoidCallback? onTap;
//   final VoidCallback? onMenuTap;

//   const ScheduleCardWidget({
//     super.key,
//     required this.schedule,
//     this.onTap,
//     this.onMenuTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final category = _getCategoryFromTaskCategory(schedule.activityCategory);
    
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(16),            decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border(
//                 left: BorderSide(
//                   color: category.textColor,
//                   width: 4,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Category and Task Type Badges
//                       Row(
//                         children: [
//                           _buildCategoryBadge(category),
//                           const SizedBox(width: 8),
//                           _buildTaskTypeBadge(),
//                           const SizedBox(width: 8),
//                           Icon(
//                             Icons.access_time,
//                             size: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
                      
//                       // Activity Title
//                       Text(
//                         schedule.activityTitle,
//                         style: GoogleFonts.plusJakartaSans(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
                      
//                       // Time Information
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.circle,
//                             size: 8,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             _getTimeDisplay(),
//                             style: GoogleFonts.plusJakartaSans(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Menu Button
//                 IconButton(
//                   onPressed: onMenuTap,
//                   icon: const Icon(
//                     Icons.more_vert,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildCategoryBadge(CategoryOption category) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: category.backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: category.textColor.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SvgPicture.asset(
//             category.iconPath,
//             width: 12,
//             height: 12,
//             colorFilter: ColorFilter.mode(
//               category.textColor,
//               BlendMode.srcIn,
//             ),
//           ),          const SizedBox(width: 4),
//           Text(
//             category.name,
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: category.textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTaskTypeBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.blue.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.assignment,
//             size: 12,
//             color: Colors.blue,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             'Tugas',
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getTimeDisplay() {
//     final duration = schedule.estimatedDuration;
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes % 60;
    
//     if (hours > 0) {
//       return 'Estimasi: ${hours} jam${minutes > 0 ? ' ${minutes} menit' : ''}';
//     } else {
//       return 'Estimasi: ${minutes} menit';
//     }
//   }
//   CategoryOption _getCategoryFromTaskCategory(TaskCategory taskCategory) {
//     switch (taskCategory) {
//       case TaskCategory.akademik:
//         return categories[0]; // Akademik
//       case TaskCategory.hiburan:
//         return categories[1]; // Hiburan
//       case TaskCategory.pekerjaan:
//         return categories[2]; // Pekerjaan
//       case TaskCategory.olahraga:
//         return categories[3]; // Olahraga
//       case TaskCategory.sosial:
//         return categories[4]; // Sosial
//       case TaskCategory.spiritual:
//         return categories[5]; // Spiritual
//       case TaskCategory.pribadi:
//         return categories[6]; // Pribadi
//       case TaskCategory.istirahat:
//         return categories[7]; // Istirahat
//     }
//   }
// }