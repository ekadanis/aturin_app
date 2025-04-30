import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_services.dart';
import '../widgets/filter_tabs.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/widgets/bottom_navbar.dart';
import '../../../../routers/app_router.dart';
import '../widgets/task_list_view.dart';
import '../widgets/snackbar.dart';

@RoutePage()
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with WidgetsBindingObserver {
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Terlambat',
    'Belum Selesai',
    'Selesai',
  ];
  bool _showSuccessMessage = false;
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskService>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          'Tugas',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: Column(
        children: [
          // Filter tabs
          FilterTabs(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          // Task list
          Expanded(
            child: Consumer<TaskService>(
              builder: (context, taskService, child) {
                // // Check if tasks are loading
                // if (taskService.isLoading) {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }

                final filteredTasks = taskService.getTasksByFilter(
                  _selectedFilter,
                );

                return TaskListView(tasks: filteredTasks);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: FloatingActionButton(
          onPressed: () {
            // Menggunakan AutoRoute alih-alih Navigator.push
            context.pushRoute(AddTaskRoute()).then((result) {
              if (result == true) {
                Provider.of<TaskService>(context, listen: false).fetchTasks();
                showCustomTopSnackbar(
                  context: context,
                  message: 'Berhasil menambahkan tugas',
                );
              }
            });
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: AppTheme.buttonBackgroundColor),
        ),
      ),

      // Menggunakan bottom navbar custom yang sudah ada
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }
}
