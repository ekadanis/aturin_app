import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/core/widgets/categories.dart';
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
    final typeLabel = _getTypeLabel(activity);
    final durationText = _getDurationText(activity);
    final hasAlarm = activity.alarm != null;
    final typeIconPath = typeLabel == 'Tugas'
        ? 'assets/icons/task-list.svg'
        : 'assets/icons/activity.svg';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 0.4.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Category badge
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
                            SizedBox(width: 1.5.w),
                            
                            // Type badge
                            _buildBadge(
                              icon: SvgPicture.asset(
                                typeIconPath, 
                                width: 3.w, 
                                height: 3.w,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF5263F3),
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: typeLabel,
                              bgColor: const Color(0xFFDFEAFF),
                              textColor: const Color(0xFF5263F3),
                            ),
                            SizedBox(width: 1.5.w),
                            
                            // Alarm badge
                            if (hasAlarm)
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
                        ),
                        SizedBox(height: 0.7.h),
                        
                        // Title
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
                        
                        // Duration
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
                  
                  // Menu button
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      offset: Offset(0, 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFFCE73),
                          width: 1,
                        ),
                      ),
                      color: const Color(0xFFFFF9F0),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
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
                ],
              ),
            ),
            
            // Left indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2.w,
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