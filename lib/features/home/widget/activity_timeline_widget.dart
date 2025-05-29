import 'package:aturin_app/features/home/widget/activity_card.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ActivityTimelineWidget extends StatelessWidget {
  const ActivityTimelineWidget({
    super.key,
    required this.activity,
    required this.index,
    required this.isLast,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final AktivitasModel activity;
  final int index;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _getTypeLabel(AktivitasModel schedule) {
    if (schedule.slug != null) {
      final slugLower = schedule.slug!.toLowerCase();
      if (slugLower.contains('tugas')) {
        return 'Tugas';
      } else if (slugLower.contains('aktivitas')) {
        return 'Aktivitas';
      }
    }
    
    if (schedule.activityTitle.toLowerCase().contains('tugas') ||
        schedule.activityCategory == ActivityCategory.akademik) {
      return 'Tugas';
    }
    return 'Aktivitas';
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = _getTypeLabel(activity);
    final isTask = typeLabel == 'Tugas';
    
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator: DottedTimelineIndicator(isTask: isTask),
        startConnector: index == 0
            ? null
            : DashedLineConnector(
                color: Colors.grey.shade400,
                dash: 5,
                gap: 6,
              ),
        endConnector: isLast
            ? null
            : DashedLineConnector(
                color: Colors.grey.shade400,
                dash: 5,
                gap: 6,
              ),
      ),
      contents: Container(
        margin: EdgeInsets.only(
          top: index == 0 ? 0 : 4.0,
          bottom: isLast ? 0 : 4.0,
        ),
        padding: const EdgeInsets.only(left: 8.0),        child: ActivityCard(
          activity: activity,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

class DottedTimelineIndicator extends StatelessWidget {
  final bool isTask;

  const DottedTimelineIndicator({
    super.key,
    required this.isTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTask ? Colors.grey.shade300 : Colors.grey.shade400,
      ),
      child: isTask
          ? CustomPaint(
              painter: DottedCirclePainter(),
            )
          : null,
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Menggambar bintik-bintik kecil di dalam circle
    final dotRadius = radius * 0.15;
    final dotPositions = [
      Offset(center.dx - radius * 0.4, center.dy - radius * 0.4),
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.4),
      Offset(center.dx - radius * 0.4, center.dy + radius * 0.4),
      Offset(center.dx + radius * 0.4, center.dy + radius * 0.4),
      Offset(center.dx, center.dy),
    ];

    for (final position in dotPositions) {
      canvas.drawCircle(position, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}