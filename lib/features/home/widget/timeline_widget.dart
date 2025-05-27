import 'package:aturin_app/features/task/ui/widgets/task_card.dart';
import 'package:aturin_app/features/task/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.task,
    required this.index,
    required this.isLast,
    required this.previousIsFlagged,
  });

  final Task task;
  final int index;
  final bool isLast;
  final bool previousIsFlagged;

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator:
            task.status == TaskStatus.completed
                ? const DotIndicator(
                  size: 24,
                  color: Colors.green,
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                )
                : const DotIndicator(size: 24, color: Colors.red),
        startConnector:
            index == 0
                ? null
                : DashedLineConnector(
                  color: Colors.grey,
                  dash: 5,
                  gap: 6,
                  indent:
                      index == 1
                          ? (previousIsFlagged ? 2.5 : 0.5) // untuk card ke-2
                          : (previousIsFlagged
                              ? 8
                              : 6), // card ke-3 dan seterusnya
                ),
        endConnector:
            isLast
                ? null
                : DashedLineConnector(
                  color: Colors.grey,
                  dash: 5,
                  gap: 6,
                  indent: index == 0 ? 7.0 : 1.5,
                ),
      ),
      contents: Container(
        // Menambahkan margin atas dan bawah untuk membuat gap antar card
        margin: EdgeInsets.only(
          top:
              index == 0
                  ? 0
                  : 4.0, // Tidak perlu margin atas untuk card pertama
          bottom:
              isLast ? 0 : 4.0, // Tidak perlu margin bawah untuk card terakhir
        ),
        padding: const EdgeInsets.only(left: 8.0),
        // child: TaskCard(
        //   task: task,
        //   onToggleCompletion: onToggleCompletion,
        //   onDelete: onDelete,
        //   onViewDetails: onViewDetails,
        //   onToggleAlarm: onToggleAlarm,
        //   currentFilter: currentFilter,
        // ),
      ),
    );
  }
}
