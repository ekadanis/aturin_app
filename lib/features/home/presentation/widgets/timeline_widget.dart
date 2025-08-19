import 'package:aturin_app/features/task/presentation/widgets/task_card.dart';
import 'package:aturin_app/features/task/data/model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.task,
    required this.index,
    required this.isLast,
    required this.previousIsFlagged,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onToggleAlarm,
    required this.onViewDetails,
    required this.currentFilter,
  });

  final Task task;
  final int index;
  final bool isLast;
  final bool previousIsFlagged;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onToggleAlarm;
  final VoidCallback onViewDetails;
  final String currentFilter;

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator:
            task.isCompleted
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
                          ? (previousIsFlagged ? 2 : 0) // untuk card ke-2
                          : (previousIsFlagged
                              ? 2
                              : 0), // card ke-3 dan seterusnya
                ),
        endConnector:
            isLast
                ? null
                : DashedLineConnector(
                  color: Colors.grey,
                  dash: 5,
                  gap: 6,
                  indent: index == 0 ? 2.5 : 4,
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
        padding: const EdgeInsets.only(left: 0.0),
        child: TaskCard(
          task: task,
          currentFilter: currentFilter,
          onToggleCompletion: onToggleCompletion,
          onDelete: onDelete,
          onViewDetails: onViewDetails,
          onToggleAlarm: onToggleAlarm,
          showCheckbox: false,
          removeMargin: false,
        ),
      ),
    );
  }
}
