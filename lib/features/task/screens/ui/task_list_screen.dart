import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/core/utils/tap_protection.dart';

import '../../../../../../core/widgets/bottom_navbar.dart';
import '../../../../../../routers/app_router.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/task_list_view.dart';
import '../widgets/snackbar.dart';

@RoutePage()
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with WidgetsBindingObserver, TapProtectionMixin {
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Hari Ini',
    'Terlambat',
    'Belum Selesai',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No need to fetch tasks here, TaskListView will fetch from API
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        safeNavigate(() {
          context.router.pushAndPopUntil(
            const HomeRoute(),
            predicate: (_) => false
          );
        });
        return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Tugas',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -8),
                child: FilterTabs(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  overdueTasksCount: 0, // Optionally, can be updated if needed
                  onFilterSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ),
              Expanded(
                child: TaskListView(
                  currentFilter: _selectedFilter,
                  onTapTask: (task) {
                    safeOnTap(() {
                      context.router.push(TaskDetailRoute(task: task)).then((result) {
                        if (result == true) {
                          // TaskListView will refresh itself
                          showCustomTopSnackbar(
                            context: context,
                            message: 'Tugas berhasil diperbarui',
                          );
                        }
                      });
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 2),
      ),
    );
  }
}
