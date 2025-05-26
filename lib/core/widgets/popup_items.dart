import 'package:aturin_app/core/widgets/delete_pop_up.dart';
import 'package:aturin_app/features/task/models/task_model.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopupItems extends StatelessWidget {
  final int currentIndex;
  final Task task;

  const PopupItems({super.key, required this.currentIndex, required this.task});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
    // Column(
    //   children: [
    //     Container(
    //   width: 117,
    //   padding: const EdgeInsets.all(12),
    //   decoration: ShapeDecoration(
    //     color: const Color(0xFFFFF9EB),
    //     shape: RoundedRectangleBorder(
    //       side: const BorderSide(
    //         width: 1,
    //         color: Color(0xFFFFC550),
    //       ),
    //       borderRadius: BorderRadius.circular(12),
    //     ),
    //   ),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       GestureDetector(
    //         onTap: () {
    //           context.pushRoute(TaskDetailRoute(task: task));
    //         },
    //         child: Text(
    //           'Ubah',
    //           style: GoogleFonts.plusJakartaSans(
    //             fontSize: 12,
    //             fontWeight: FontWeight.w400,
    //             color: Colors.black,
    //           ),
    //         ),
    //       ),
    //       const SizedBox(height: 12),
    //       GestureDetector(
    //         onTap: (dynamic task) {
    //           DeletePopUp(id: task.id, category: task.category, title: task.title);
    //         },
    //         child: Text(
    //           'Hapus',
    //           style: GoogleFonts.plusJakartaSans(
    //             fontSize: 12,
    //             fontWeight: FontWeight.w400,
    //             color: const Color(0xFFEE443F),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    //   ],
    );
  }
}
