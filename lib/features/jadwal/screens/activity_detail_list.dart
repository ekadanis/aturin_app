import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/features/jadwal/widgets/activity_detail_card.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class ActivityDetailListPage extends StatefulWidget {
  final List<AktivitasModel>? activities;
  final int? initialIndex;
  
  const ActivityDetailListPage({
    super.key,
    this.activities,
    this.initialIndex,
  });

  @override
  State<ActivityDetailListPage> createState() => _ActivityDetailListPageState();
}

class _ActivityDetailListPageState extends State<ActivityDetailListPage> {
  late final PageController _pageController;
  int _currentPageIndex = 0;
  late List<AktivitasModel> displayActivities;

  @override
  void initState() {
    super.initState();
    displayActivities = widget.activities ?? _getDummyActivities();
    _currentPageIndex = widget.initialIndex ?? 0;
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _currentPageIndex,
    );
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      final newIndex = page.round();
      if (newIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newIndex;
        });
      }
    });
  }

  List<AktivitasModel> _getDummyActivities() {
    return [
      AktivitasModel(
        id: 1,
        activityTitle: 'Nonton DBL Hari ini a',
        activityDate: DateTime(2025, 5, 20),
        activityStartTime: DateTime(2025, 5, 20, 8, 0),
        activityCompleteTime: DateTime(2025, 5, 20, 12, 0),
        activityCategory: ActivityCategory.hiburan,
        alarmId: null,
      ),
      AktivitasModel(
        id: 2,
        activityTitle: 'Meeting Klien',
        activityDate: DateTime(2025, 5, 21),
        activityStartTime: DateTime(2025, 5, 21, 9, 0),
        activityCompleteTime: DateTime(2025, 5, 21, 11, 0),
        activityCategory: ActivityCategory.pekerjaan,
        alarmId: 123,
      ),
      // Tambahkan dummy data lain jika perlu
    ];
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_detail.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 2.h,
                left: 4.w,
                right: 4.w,
                bottom: 2.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.router.pop(),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Detail Aktivitas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: const Color(0xFF131927),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: displayActivities.length,
                      itemBuilder: (context, index) {
                        final activity = displayActivities[index];
                        final isSelected = index == _currentPageIndex;
                        return AnimatedScale(
                          scale: isSelected ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: DetailActivityCard(
                            title: activity.activityTitle,
                            date: _formatDate(activity.activityDate),
                            startTime: _formatTime(activity.activityStartTime),
                            completeTime: _formatTime(activity.activityCompleteTime),
                            category: activity.activityCategory.displayName,
                            alarmId: activity.alarmId?.toString(),
                            isSelected: isSelected,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 4.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/activitycategory/edit-pencil.svg',
                        width: 6.w,
                        height: 6.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {
                    showDeleteDialog(context);
                  },
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/activitycategory/trash.svg',
                        width: 6.w,
                        height: 6.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showDeleteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (_) => ConfirmDialog(
          iconPath: 'assets/activitycategory/trash-round-tipis.svg',
          title: 'Hapus Aktivitas',
          description: 'Yakin nih kamu mau hapus aktivitas?',
          confirmText: 'Hapus',
          cancelText: 'Batal',
          onConfirm: () {
            print('Aktivitas dihapus!');
          },
        ),
  );
}
