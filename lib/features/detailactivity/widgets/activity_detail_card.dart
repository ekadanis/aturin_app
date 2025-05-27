import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/features/detailactivity/widgets/category.dart';
import 'package:aturin_app/features/detailactivity/widgets/chip.dart';

class DetailActivityCard extends StatelessWidget {
  final String title;
  final String date;
  final String startTime;
  final String completeTime;
  final String category;
  final String? alarmId;
  final bool isSelected;

  const DetailActivityCard({
    super.key,
    required this.title,
    required this.date,
    required this.startTime,
    required this.completeTime,
    required this.category,
    this.alarmId,
    this.isSelected = false,
  });

  CategoryOption _getCategoryDetails() {
    return categories.firstWhere(
      (item) => item.name == category,
      orElse: () => categories.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetails = _getCategoryDetails();

    final normalWidth = 85.w;
    final normalHeight = 65.h;

    final width = isSelected ? normalWidth + 2.w : normalWidth;
    final height = isSelected ? normalHeight + 2.h : normalHeight;

    final headerHeight = height * 2 / 3 - 4.h;

    return SizedBox(
      width: width,
      child: OverflowBox(
        maxHeight: height,
        minHeight: height,
        child: Card(
          elevation: isSelected ? 8 : 0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200, width: 0.3.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: categoryDetails.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 2.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.w),
                      Positioned(
                        top: 7.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.only(
                              right: 12.w,
                              left: 12.w,
                              top: 4.w,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 14.h),
                            Image.asset(
                              categoryDetails.iconPath,
                              width: 25.w,
                              height: 12.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bagian bawah card
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: Offset(7.8.w, -1.95.h),
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          height: 3.h,
                          width: 18.w,
                          decoration: BoxDecoration(
                            color: categoryDetails.color,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 3.h,
                      width: 26.w,
                      decoration: BoxDecoration(
                        color: categoryDetails.color,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-7.8.w, -1.95.h),
                      child: Transform.rotate(
                        angle: -0.785398,
                        child: Container(
                          height: 3.h,
                          width: 18.w,
                          decoration: BoxDecoration(
                            color: categoryDetails.color,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 0.3.h,
                        width: 13.w,
                        decoration: BoxDecoration(
                          color: categoryDetails.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      SvgPicture.asset(
                        'assets/activitycategory/time.svg',
                        width: 4.w,
                        color: categoryDetails.color,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$startTime - $completeTime',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: categoryDetails.color,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        height: 0.3.h,
                        width: 13.w,
                        decoration: BoxDecoration(
                          color: categoryDetails.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomChip(
                        iconPath: categoryDetails.iconChip,
                        label: categoryDetails.name,
                        foregroundColor: categoryDetails.color,
                        backgroundColor: categoryDetails.color.withOpacity(
                          0.15,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomChip(
                        iconPath:
                            'assets/activitycategory/chipicon/aktivitas.svg',
                        label: 'Aktivitas',
                        foregroundColor: Color(0xFF5263F3),
                        backgroundColor: Color(0xFF5263F3).withOpacity(0.15),
                      ),
                      SizedBox(width: 3.w),
                      if (alarmId != null) ...[
                        CustomChip(
                          iconPath:
                              'assets/activitycategory/chipicon/alarm2.svg',
                          foregroundColor: Color(0xFF5263F3),
                          backgroundColor: Color(0xFF5263F3).withOpacity(0.15),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
