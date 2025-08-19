// import 'package:aturin_app/core/widgets/delete_popup.dart';
// import 'package:aturin_app/core/widgets/popup_items.dart';
// import 'package:aturin_app/features/task/models/task_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:panara_dialogs/panara_dialogs.dart';
// import 'package:popover/popover.dart';

// import 'package:aturin_app/core/theme/app_theme.dart';
// import 'package:aturin_app/routers/app_router.dart';
// import 'package:aturin_app/core/utils/debouncer.dart';
// import 'package:aturin_app/features/task/ui/widgets/task_card.dart';
// import 'package:path/path.dart';

// class EditPopup extends StatelessWidget {
//   final int currentIndex;
//   final Task task;

//   const EditPopup({
//     super.key,
//     required this.currentIndex, required this.task,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final task = TaskService().tasks[currentIndex];
//     return Placeholder();
//     // return GestureDetector(
//     //   onTap: () => showPopover(
//     //     context: context, 
//     //     bodyBuilder: (context) => PopupItems(),
//     //   ),
//     // );
//     // return Container(
//     //   width: 117,
//     //   padding: const EdgeInsets.all(12),
//     //   decoration: ShapeDecoration(
//     //     color: const Color(0xFFFFF9EB),
//     //     shape: RoundedRectangleBorder(
//     //       side: const BorderSide(
//     //         width: 1,
//     //         color: Color(0xFFFFC550),
//     //       ),
//     //       borderRadius: BorderRadius.circular(12),
//     //     ),
//     //   ),
//     //   child: Column(
//     //     mainAxisSize: MainAxisSize.min,
//     //     crossAxisAlignment: CrossAxisAlignment.start,
//     //     children: [
//     //       GestureDetector(
//     //         onTap: () {
//     //           context.pushRoute(TaskDetailRoute(task: task));
//     //         },
//     //         child: Text(
//     //           'Ubah',
//     //           style: GoogleFonts.plusJakartaSans(
//     //             fontSize: 12,
//     //             fontWeight: FontWeight.w400,
//     //             color: Colors.black,
//     //           ),
//     //         ),
//     //       ),
//     //       const SizedBox(height: 12),
//     //       GestureDetector(
//     //         onTap: () {
//     //           DeletePopup(id: task.id, category: task.category, title: task.title);
//     //         },
//     //         child: Text(
//     //           'Hapus',
//     //           style: GoogleFonts.plusJakartaSans(
//     //             fontSize: 12,
//     //             fontWeight: FontWeight.w400,
//     //             color: const Color(0xFFEE443F),
//     //           ),
//     //         ),
//     //       ),
//     //     ],
//     //   ),
//     // );
//   }
// }

