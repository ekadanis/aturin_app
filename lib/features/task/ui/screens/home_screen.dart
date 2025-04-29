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
                    label: Text(tabs[index],overflow: TextOverflow.visible,),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedTabIndex = index);
                    },
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: Colors.white10,
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
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(existingTask: task),
                      ),
                    );
                    if (result == true) {
                      _loadTasks(); // reload data setelah edit
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(task),
                  ),
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

  void _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Tugas'),
            content: const Text('Yakin ingin menghapus tugas ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      await _taskService.deleteTask(task.id!); // pastikan ID tidak null
      _loadTasks();
    }
  }
}
