import 'package:aturin_app/features/home/services/task_service.dart';
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/timeline_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool taskEmpty = TaskService.tasks.isEmpty;
    final tasks = TaskService.tasks;
    return Scaffold(
      appBar: GreetingHeader(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Tugas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child:
                    taskEmpty
                        ? Center(child: EmptyTask())
                        : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final isLast = index == tasks.length - 1;

                            return TimelineWidget(
                              task: task,
                              index: index,
                              isLast: isLast,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
