import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import 'task_card.dart';
import '../screens/task_detail_screen.dart';
import 'snackbar.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;

  const TaskListView({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada tugas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TaskCard(
            task: task,
            onToggleCompletion: () {
              Provider.of<TaskService>(
                context,
                listen: false,
              ).toggleTaskCompletion(task.id);
              if (!task.isCompleted) {
                showCustomTopSnackbar(
                  context: context,
                  message: 'Berhasil Menyelesaikan Tugas',
                );
              }
            },
            onDelete: () {
              Provider.of<TaskService>(
                context,
                listen: false,
              ).deleteTask(task.id);
              showCustomTopSnackbar(
                context: context,
                message: 'Berhasil menghapus tugas',
              );
            },
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(task: task),
                ),
              );
            },
            onToggleAlarm: () {
              Provider.of<TaskService>(
                context,
                listen: false,
              ).toggleAlarm(task.id);
            },
          ),
        );
      },
    );
  }
}
