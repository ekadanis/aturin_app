import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/features/jadwal/widgets/activity_detail_card.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/widgets/custom_snackbar_top.dart';

@RoutePage()
class ActivityDetailListPage extends StatefulWidget {
  final List<AktivitasModel>? activities;
  final int? initialIndex;

  const ActivityDetailListPage({super.key, this.activities, this.initialIndex});

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
    // Filter hanya aktivitas di tanggal yang sama dengan initialIndex
    if ((widget.activities?.isNotEmpty ?? false) &&
        widget.initialIndex != null) {
      final initial = widget.activities![widget.initialIndex!];
      final sameDate = initial.activityDate;
      displayActivities =
          widget.activities!
              .where(
                (a) =>
                    a.activityDate.year == sameDate.year &&
                    a.activityDate.month == sameDate.month &&
                    a.activityDate.day == sameDate.day,
              )
              .toList();
      // Cari index baru dari initial di list terfilter
      _currentPageIndex = displayActivities.indexWhere(
        (a) => a.id == initial.id,
      );
      if (_currentPageIndex == -1) _currentPageIndex = 0;
    } else {
      displayActivities = widget.activities ?? [];
      _currentPageIndex = widget.initialIndex ?? 0;
    }
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

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
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
  Future<void> _handleDeleteActivity() async {
    if (displayActivities.isEmpty) return;

    final currentActivity = displayActivities[_currentPageIndex];

    try {
      final activityApiService = Provider.of<ActivityApiService>(
        context,
        listen: false,
      );

      if (currentActivity.slug != null) {
        // Show loading indicator
        if (mounted) {
          showCustomTopSnackbar(
            context: context,
            message: 'Menghapus aktivitas...',
            isError: false,
          );
        }

        final success = await activityApiService.deleteActivity(currentActivity.slug!);

        if (success) {
          // Remove activity from local list
          setState(() {
            displayActivities.removeAt(_currentPageIndex);

            // Adjust current page index if needed
            if (_currentPageIndex >= displayActivities.length && displayActivities.isNotEmpty) {
              _currentPageIndex = displayActivities.length - 1;
            }
          });

          // Show success message
          if (mounted) {
            showCustomTopSnackbar(
              context: context,
              message: 'Aktivitas berhasil dihapus',
              isError: false,
            );
          }          // Navigate back if no more activities
          if (displayActivities.isEmpty) {
            // Return true to indicate data changed, so parent can refresh
            Navigator.pop(context, true);
          } else {
            // Animate to adjusted page
            _pageController.animateToPage(
              _currentPageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // Show error message
          if (mounted) {
            showCustomTopSnackbar(
              context: context,
              message: 'Gagal menghapus aktivitas dari server',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: 'Gagal menghapus aktivitas: ${e.toString()}',
          isError: true,
        );
      }
    }
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
                    children: [                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.router.pop(true), // Return true to indicate potential data changes
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
                            completeTime: _formatTime(
                              activity.activityCompleteTime,
                            ),
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
              children: [                GestureDetector(
                  onTap: () async {
                    // Routing ke edit aktivitas
                    final currentActivity =
                        displayActivities[_currentPageIndex];
                    final result = await context.router.push(
                      AddAktivitasRoute(existingAktivitas: currentActivity),
                    );
                    
                    // If edit was successful, the aktivitas screen will auto-refresh
                    // due to the Consumer2 pattern, no need to manually refresh here
                    if (result == true && mounted) {
                      // Optional: Show success message or update local display
                      print('📝 Edit completed, parent screen will auto-refresh');
                    }
                  },
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
                SizedBox(width: 16.w),                GestureDetector(
                  onTap: () {
                    // Routing ke hapus aktivitas
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        iconPath: 'assets/activitycategory/trash-round-tipis.svg',
                        title: 'Hapus Aktivitas',
                        description: 'Yakin nih kamu mau hapus aktivitas?',
                        confirmText: 'Hapus',
                        cancelText: 'Batal',
                        isTask: false,
                        onConfirm: () {
                          Navigator.pop(context); // Close dialog
                          _handleDeleteActivity(); // Handle delete activity
                        },
                      ),
                    );
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
  // void _removeActivityAndSlide(AktivitasModel aktivitas) {
  //   final idx = displayActivities.indexWhere((a) => a.id == aktivitas.id);
  //   if (idx != -1) {
  //     setState(() {
  //       displayActivities.removeAt(idx);
  //       if (displayActivities.isEmpty) {
  //         // Jika tidak ada activity tersisa, kembali ke halaman sebelumnya
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           if (mounted) {
  //             // Pop back to aktivitas screen - will refresh automatically
  //             Navigator.of(context).pop(true); // Pass true to indicate data changed
  //           }
  //         });
  //       } else {
  //         // Jika masih ada activity lain, slide ke activity berikutnya
  //         if (_currentPageIndex >= displayActivities.length) {
  //           _currentPageIndex = displayActivities.length - 1;
  //         }
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           if (mounted && _pageController.hasClients) {
  //             _pageController.animateToPage(
  //               _currentPageIndex,
  //               duration: const Duration(milliseconds: 300),
  //               curve: Curves.easeInOut,
  //             );
  //           }
  //         });
  //       }
  //     });
  //   }
  // }
}
