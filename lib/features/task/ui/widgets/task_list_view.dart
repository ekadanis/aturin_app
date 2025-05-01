import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import 'task_card.dart';
import '../screens/task_detail_screen.dart';
import 'snackbar.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final void Function(String)? onShowSuccess;
  final void Function(Task)? onTapTask;
  final String currentFilter; 

  const TaskListView({
    Key? key,
    required this.tasks,
    this.onShowSuccess,
    this.onTapTask,
    required this.currentFilter,
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
            currentFilter: currentFilter, 
            onToggleCompletion: () {
              final taskService = Provider.of<TaskService>(
                context,
                listen: false,
              );
              taskService.toggleTaskCompletion(task.id);

              if (!task.isCompleted) {
                showCustomTopSnackbar(
                  context: context,
                  message: 'Berhasil Menyelesaikan Tugas',
                );
              } else {
                showCustomTopSnackbar(
                  context: context,
                  message: 'Tugas dikembalikan ke status sebelumnya',
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
              onTapTask?.call(task);
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
