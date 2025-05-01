import 'package:aturin_app/features/home/models/task_model.dart';
import 'package:aturin_app/features/home/widget/task_card.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({
    super.key,
    required this.task,
    required this.index,
    required this.isLast,
  });

  final Task task;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator: task.status == TaskStatus.selesai
            ? const DotIndicator(
                size: 24,
                color: Colors.green,
                child: Icon(Icons.check, size: 16, color: Colors.white),
              )
            : const OutlinedDotIndicator(
                size: 24,
                borderWidth: 2,
                color: Colors.red,
              ),
        startConnector:
            index == 0
                ? null
                : DashedLineConnector(
                  color: Colors.grey,
                  dash: 5,
                  gap: 6, 
                  indent: 5.5,
                ),
        endConnector:
            isLast
                ? null
                : const DashedLineConnector(
                  color: Colors.grey,
                  dash: 5,
                  gap: 6,
                  indent: 1,
                ),
      ),
      contents: Container(
        // Menambahkan margin atas dan bawah untuk membuat gap antar card
        margin: EdgeInsets.only(
          top: index == 0 ? 0 : 4.0,  // Tidak perlu margin atas untuk card pertama
          bottom: isLast ? 0 : 4.0,   // Tidak perlu margin bawah untuk card terakhir
        ),
        padding: const EdgeInsets.only(left: 8.0),
        child: TaskCard(task: task),
      ),
    );
  }
}
