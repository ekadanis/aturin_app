import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/task_model.dart';
import '../../services/task_services.dart';
import 'task_card.dart';
import 'snackbar.dart';
import 'package:sizer/sizer.dart';

class TaskListView extends StatefulWidget {
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
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/https___lottiefiles.com_animations_no-data-bt8EDsKmcr.gif',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0.75.h),
      child: Hero(
        tag: 'task-${task.id}',
        child: TaskCard(
          task: task,
          currentFilter: widget.currentFilter,
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
                message: 'Tugas kembali ke status awal',
              );
            }
          },
          onDelete: () async {
            try {
              await Provider.of<TaskService>(
                context,
                listen: false,
              ).deleteTask(task.id);

              showCustomTopSnackbar(
                context: context,
                message: 'Berhasil menghapus tugas',
              );
            } catch (e) {
              debugPrint('Error menghapus task: $e');
              showCustomTopSnackbar(
                context: context,
                message: 'Gagal menghapus tugas, coba lagi',
              );
            }
          },
          onViewDetails: () {
            widget.onTapTask?.call(task);
          },
          onToggleAlarm: () {
            Provider.of<TaskService>(
              context,
              listen: false,
            ).toggleAlarm(task.id);
          },
        ),
      ),
    );
  }
}
