import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/core/utils/tap_protection.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:provider/provider.dart';
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
    'Terlambat',
    'Belum Selesai',
    'Selesai',
  ];

  int _overdueTasksCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOverdueCount();
      Provider.of<TaskApiService>(context, listen: false).fetchTasks();
    });
  }

  Future<void> _fetchOverdueCount() async {
    final taskService = Provider.of<TaskApiService>(context, listen: false);
    final data = await taskService.countLateTasks();
    print('Data dari API: $data');
    if (data != null && data['overdue_tasks'] != null) {
      setState(() {
        _overdueTasksCount = data['overdue_tasks'] as int;
      });
    }
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
                  overdueTasksCount: _overdueTasksCount, // <-- assign di sini
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
                  onShowSuccess: (message) {
                    // reload TaskListView
                    setState(() {});
                    // reload countLateTask agar badge overdue sinkron
                    _fetchOverdueCount();
                    // tampilkan snackbar jika perlu
                    showCustomTopSnackbar(context: context, message: message);
                  },
                  onTapTask: (task) {
                    safeOnTap(() {
                      context.router.push(TaskDetailRoute(task: task)).then((result) {
                        if (result == true) {
                          setState(() {});
                          _fetchOverdueCount(); // reload countLateTask juga setelah edit
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
