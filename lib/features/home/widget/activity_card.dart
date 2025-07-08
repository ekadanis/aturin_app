import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/ui/add_aktivitas.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ActivityCard extends StatelessWidget {
  final AktivitasModel activity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  String _getTypeLabel(AktivitasModel schedule) {
    if (schedule.slug != null) {
      final slugLower = schedule.slug!.toLowerCase();
      if (slugLower.contains('tugas')) {
        return 'Tugas';
      } else if (slugLower.contains('aktivitas') ||
          slugLower.contains('activity')) {
        return 'Aktivitas';
      }
    }

    if (schedule.activityTitle.toLowerCase().contains('tugas') ||
        schedule.activityCategory == ActivityCategory.akademik) {
      return 'Tugas';
    }
    return 'Aktivitas';
  }

  bool _isCompleted() {
    // Check if activity is marked as completed
    if (activity.slug != null) {
      final slugLower = activity.slug!.toLowerCase();
      return slugLower.contains('selesai') || slugLower.contains('completed');
    }
    return false;
  }

  String _getDurationText(AktivitasModel schedule) {
    final duration = schedule.activityCompleteTime.difference(
      schedule.activityStartTime,
    );
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (_getTypeLabel(schedule) == 'Tugas') {
      if (hours > 0) {
        return 'Estimasi: ${hours} jam ${minutes} menit';
      } else {
        return 'Estimasi: ${minutes} menit';
      }
    } else {
      return '${schedule.activityStartTime.hour.toString().padLeft(2, '0')}:${schedule.activityStartTime.minute.toString().padLeft(2, '0')} - ${schedule.activityCompleteTime.hour.toString().padLeft(2, '0')}:${schedule.activityCompleteTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = categories.firstWhere(
      (c) => c.name == activity.activityCategory.displayName,
      orElse: () => categories.first,
    );
    // final typeLabel = _getTypeLabel(activity);
    final durationText = _getDurationText(activity);
    final hasAlarm = activity.alarm != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.35),
              blurRadius: 8,
              offset: Offset(0, 0),
            ),
          ],
        ),
        clipBehavior: Clip.none,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildBadge(
                              icon: SvgPicture.asset(
                                category.iconPath,
                                width: 3.w,
                                height: 3.w,
                                colorFilter: ColorFilter.mode(
                                  category.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: category.name,
                              bgColor: category.backgroundColor,
                              textColor: category.textColor,
                            ),
                            if (hasAlarm) ...[
                              SizedBox(width: 1.5.w),
                              _buildBadge(
                                icon: SvgPicture.asset(
                                  'assets/icons/alarm.svg',
                                  width: 3.w,
                                  height: 3.w,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF5263F3),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: '',
                                bgColor: const Color(0xFFDFEAFF),
                                textColor: const Color(0xFF5263F3),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 0.7.h),
                        Text(
                          activity.activityTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF131927),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        if (durationText.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                size: 3.w,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                durationText,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ), // Menu button positioned in top right corner (hidden if completed)
            if ((onEdit != null || onDelete != null) && !_isCompleted())
              Positioned(
                top: 1.h,
                right: 4.w,
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFF5263F3),
                      width: 1.5,
                    ),
                  ),
                  color: const Color.fromARGB(255, 249, 251, 255),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      // Use TaskApiService from provider
                      final activityApiService =
                          Provider.of<ActivityApiService>(
                            context,
                            listen: false,
                          );

                      // Store context to avoid async gap warning
                      final navigator = Navigator.of(context);

                      // Get latest task data from provider service
                      final latestTask =
                          activity.slug != null
                              ? await activityApiService.getActivityBySlug(
                                activity.slug!,
                              )
                              : null;

                      final result = await navigator.push(
                        MaterialPageRoute(
                          builder:
                              (_) => AddAktivitasPage(
                                existingAktivitas: latestTask ?? activity,
                              ),
                        ),
                      );

                      if (result == true) {
                        // Refresh tasks through provider
                        await activityApiService.fetchActivities();
                      }
                    } else if (value == 'delete') {
                      // Tampilkan DeletePopup
                      showDialog(
                        context: context,
                        builder:
                            (_) => ConfirmDialog(
                              onConfirm: () {
                                if (onDelete != null) {
                                  onDelete!();
                                }
                              },
                            ),
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (onEdit != null)
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Ubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: const Color(0xFFD93E39),
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: const Color(0xFFD93E39),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                  icon: Icon(Icons.more_vert, size: 5.w),
                ),
              ),

            // Left vertical indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF5263F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required Widget icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          if (label.isNotEmpty) ...[
            SizedBox(width: 1.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
