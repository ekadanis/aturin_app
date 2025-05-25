import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/features/detailactivity/widgets/category.dart';

class DetailActivityCard extends StatelessWidget {
  final String title;
  final String date;
  final String startTime;
  final String completeTime;
  final String category;
  final String? alarmId;
  final bool isSelected;  // Tambahkan properti isSelected

  const DetailActivityCard({
    super.key,
    required this.title,
    required this.date,
    required this.startTime,
    required this.completeTime,
    required this.category,
    this.alarmId,
    this.isSelected = false, // default false
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

    // Ukuran card normal
    final normalWidth = 327.0;
    final normalHeight = 560.0;

    // Ukuran card jika selected, misalnya ditambah 20 px
    final width = isSelected ? normalWidth + 20 : normalWidth;
    final height = isSelected ? normalHeight + 20 : normalHeight;

    final headerHeight = height * 2 / 3 - 32; // sesuaikan dengan ukuran total card

    return SizedBox(
      width: width,
      child: OverflowBox(
        maxHeight: height,
        minHeight: height,
        child: Card(
          elevation: isSelected ? 8 : 0, // contoh shadow beda saat selected
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header berwarna (2/3 dari tinggi card dikurangi padding)
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
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 56,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
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
                            const SizedBox(height: 128),
                            Image.asset(
                              categoryDetails.iconPath,
                              width: 90,
                              height: 90,
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
                      offset: const Offset(30, -16),
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          height: 30,
                          width: 70,
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
                      height: 30,
                      width: 100,
                      decoration: BoxDecoration(
                        color: categoryDetails.color,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-30, -16),
                      child: Transform.rotate(
                        angle: -0.785398,
                        child: Container(
                          height: 30,
                          width: 70,
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

                const SizedBox(height: 48),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 2,
                        width: 50,
                        decoration: BoxDecoration(
                          color: categoryDetails.color,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(2),
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/activitycategory/time.svg',
                        width: 16,
                        color: categoryDetails.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$startTime - $completeTime',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: categoryDetails.color,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 2,
                        width: 50,
                        decoration: BoxDecoration(
                          color: categoryDetails.color,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(2),
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 24,
                        child: SvgPicture.asset(
                          categoryDetails.category,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        height: 24,
                        child: SvgPicture.asset(
                          categoryDetails.activity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (alarmId != null) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            'assets/activitycategory/chip/alarm.svg',
                            fit: BoxFit.contain,
                          ),
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
