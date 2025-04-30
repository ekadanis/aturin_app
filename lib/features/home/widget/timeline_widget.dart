import 'package:aturin_app/features/home/models/task_model.dart';
import 'package:aturin_app/features/home/widget/task_card.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

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
        indicator: switch (task.status) {
          TaskStatus.terlambat => const DotIndicator(
            size: 24,
            color: Colors.red,
            child: Icon(Icons.priority_high, size: 16, color: Colors.white),
          ),
          TaskStatus.selesai => const DotIndicator(
            size: 24,
            color: Colors.green,
            child: Icon(Icons.check, size: 16, color: Colors.white),
          ),
          TaskStatus.besok => const OutlinedDotIndicator(
            size: 24,
            borderWidth: 2,
            color: Colors.grey,
          ),
        },
        startConnector:
            index == 0
                ? null
                : const DashedLineConnector(
                  color: Colors.grey,
                  dash: 2,
                  gap: 3,
                  endIndent: 0, // jarak dari indicator sebelumnya
                ),
        endConnector:
            isLast
                ? null
                : const DashedLineConnector(
                  color: Colors.grey,
                  dash: 2,
                  gap: 3,
                  indent: 2, // jarak dari indicator selanjutnya
                ),
      ),
      contents: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.only(left: 8.0),
        child: TaskCard(task: task),
      ),
    );
    
  }
}
