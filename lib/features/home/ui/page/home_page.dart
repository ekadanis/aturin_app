import 'package:aturin_app/features/home/models/task_model.dart';
import 'package:aturin_app/features/home/services/task_service.dart';
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/task_card.dart';
import 'package:timelines_plus/timelines_plus.dart';
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
              SizedBox(height: 32),
              Text(
                'Tugas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              Expanded(
                child:
                    taskEmpty
                        ? Center(child: EmptyTask())
                        : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TimelineTile(
                              nodeAlign: TimelineNodeAlign.start,
                              node: TimelineNode(
                                indicator: switch (task.status) {
                                  TaskStatus.terlambat => const DotIndicator(
                                    size: 24,
                                    color: Colors.red,
                                    child: Icon(
                                      Icons.priority_high,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TaskStatus.selesai => const DotIndicator(
                                    size: 24,
                                    color: Colors.green,
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TaskStatus.besok =>
                                    const OutlinedDotIndicator(
                                      size: 24,
                                      borderWidth: 2,
                                      color: Colors.grey,
                                    ),
                                },
                                startConnector:
                                    index == 0
                                        ? null
                                        : const DashedLineConnector(
                                          color: Colors.grey,
                                          dash: 2,
                                          gap: 3,
                                          endIndent:
                                              0, // jarak dari indicator sebelumnya
                                        ),
                                endConnector:
                                    index == tasks.length - 1
                                        ? null
                                        : const DashedLineConnector(
                                          color: Colors.grey,
                                          dash: 2,
                                          gap: 3,
                                          indent:
                                              2, // jarak dari indicator selanjutnya
                                        ),
                              ),
                              contents: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TaskCard(task: task),
                              ),
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
