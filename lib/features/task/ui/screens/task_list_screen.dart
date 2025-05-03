import 'package:aturin_app/features/task/ui/screens/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../services/task_services.dart';
import '../widgets/filter_tabs.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../../../core/widgets/bottom_navbar.dart';
import '../../../../../../routers/app_router.dart';
import '../widgets/task_list_view.dart';
import '../widgets/snackbar.dart';
import 'package:aturin_app/core/utils/tap_protection.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskService = Provider.of<TaskService>(
        context,
        listen: false,
      );
      taskService.fetchTasks();
      taskService.startStatusChecker();
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

        // Menggunakan SafeArea untuk mencegah konten dari terpotong oleh sistem UI
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reduced the space between AppBar and filter tabs by adding negative margin
              Transform.translate(
                offset: const Offset(0, -8),
                child: Consumer<TaskService>(
                  builder: (context, taskService, _) {

                    final overdueTasksCount = taskService.getTasksByFilter('Terlambat').length;

                    return FilterTabs(
                      filters: _filters,
                      selectedFilter: _selectedFilter,
                      overdueTasksCount: overdueTasksCount,
                      onFilterSelected: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    );
                  },
                ),
              ),

              // Daftar tugas - dengan padding bawah dimodifikasi untuk memberikan ruang tambahan
              Expanded(
                child: Consumer<TaskService>(
                  builder: (context, taskService, _) {
                    final filteredTasks = taskService.getTasksByFilter(
                      _selectedFilter,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 0), // Menghilangkan padding bawah default
                      child: TaskListView(
                        tasks: filteredTasks,
                        currentFilter: _selectedFilter,
                        onTapTask: (task) {
                          safeOnTap(() {
                            context.router.push(TaskDetailRoute(task: task)).then((
                              result,
                            ) {
                              if (result == true) {
                                Provider.of<TaskService>(
                                  context,
                                  listen: false,
                                ).fetchTasks();
                                showCustomTopSnackbar(
                                  context: context,
                                  message: 'Tugas berhasil diperbarui',
                                );
                              }
                            });
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: FloatingActionButton(
            onPressed: () {
              safeOnTap(() {
                context.pushRoute(AddTaskRoute()).then((result) {
                  if (result == true) {
                    Provider.of<TaskService>(context, listen: false).fetchTasks();
                    showCustomTopSnackbar(
                      context: context,
                      message: 'Berhasil menambahkan tugas',
                    );
                  }
                });
              });
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: AppTheme.buttonBackgroundColor),
          ),
        ),

        // Biarkan extendBody tetap false (default)
        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      ),
    );
  }
}
