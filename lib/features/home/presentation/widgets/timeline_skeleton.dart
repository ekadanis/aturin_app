import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:shimmer/shimmer.dart';

class TimelineSkeleton extends StatelessWidget {
  final int index;
  final bool isLast;

  const TimelineSkeleton({
    Key? key,
    required this.index,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator: const OutlinedDotIndicator(
          size: 24,
          borderWidth: 2,
          color: Colors.grey,
        ),
        startConnector:
            index == 0
                ? null
                : const SolidLineConnector(
                    color: Colors.grey,
                  ),
        endConnector:
            isLast
                ? null
                : const SolidLineConnector(
                    color: Colors.grey,
                  ),
      ),
      contents: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 16),
        child: _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: AppTheme.lightDividerColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT SIDE (info tugas)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 60,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Judul tugas skeleton
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Deadline skeleton
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 40,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // RIGHT SIDE (Status badge) skeleton
                  Container(
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}