import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import 'add_task_screen.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  int selectedTabIndex = 0;

  final List<String> tabs = ['Semua', 'Terlambat', 'Belum Selesai'];

  Future<void> _loadTasks() async {
    final tasks = await _taskService.getAllTasks();
    setState(() => _tasks = tasks);
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halo Danis!'), elevation: 100),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ChoiceChip(
                    label: Text(tabs[index]),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedTabIndex = index);
                    },
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.secondaryTextColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('Deadline: ${task.deadline.toLocal()}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
