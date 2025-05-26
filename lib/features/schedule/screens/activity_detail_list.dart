import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/features/schedule/widgets/activity_detail_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';

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
  ];

  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
    ); // Card agak kecil biar keliatan preview card lain
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
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
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
                      const SizedBox(width: 16),
                      const Text(
                        'Detail Aktivitas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                            isSelected:
                                isSelected, // Kirim status selected ke card
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/activitycategory/edit-pencil.svg',
                    ),
                  ),
                ),
                const SizedBox(width: 64),
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ConfirmDialog(),
                    );
                    if (confirm == true) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/activitycategory/trash.svg',
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
