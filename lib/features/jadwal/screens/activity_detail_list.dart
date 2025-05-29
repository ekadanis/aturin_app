import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/features/jadwal/widgets/activity_detail_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class ActivityDetailListPage extends StatefulWidget {
  const ActivityDetailListPage({super.key});

  @override
  State<ActivityDetailListPage> createState() => _ActivityDetailListPageState();
}

class _ActivityDetailListPageState extends State<ActivityDetailListPage> {
  final List<Map<String, String?>> activityData = const [
    {
      'title': 'Nonton DBL Hari ini a',
      'date': '20 Mei 2025',
      'startTime': '08:00',
      'completeTime': '12:00',
      'category': 'Hiburan',
      'alarmId': null,
    },
    {
      'title': 'Meeting Klien',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Pekerjaan',
      'alarmId': '123',
    },
    {
      'title': 'Push up 1000 kali',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Olahraga',
      'alarmId': '123',
    },
    {
      'title': 'Membuat Roket',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Akademik',
      'alarmId': '123',
    },
    {
      'title': 'Bersholawat',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Spiritual',
      'alarmId': '123',
    },
    {
      'title': 'Ngomong',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Sosial',
      'alarmId': '123',
    },
    {
      'title': 'Healing',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Pribadi',
      'alarmId': '123',
    },
    {
      'title': 'Scroll Ig',
      'date': '21 Mei 2025',
      'startTime': '09:00',
      'completeTime': '11:00',
      'category': 'Istirahat',
      'alarmId': '123',
    },
  ];

  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
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
                      itemCount: activityData.length,
                      itemBuilder: (context, index) {
                        final activity = activityData[index];
                        final isSelected = index == _currentPageIndex;
                        return AnimatedScale(
                          scale: isSelected ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: DetailActivityCard(
                            title: activity['title']!,
                            date: activity['date']!,
                            startTime: activity['startTime']!,
                            completeTime: activity['completeTime']!,
                            category: activity['category']!,
                            alarmId: activity['alarmId'],
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
