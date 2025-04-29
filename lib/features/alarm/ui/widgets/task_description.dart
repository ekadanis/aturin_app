// lib/widgets/task_description.dart
import 'package:flutter/material.dart';

class TaskDescription extends StatelessWidget {
  final String taskName;
  
  const TaskDescription({
    Key? key,
    required this.taskName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Satu tugas beres, Satu beban hilang!",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '"',
              style: TextStyle(fontSize: 30),
            ),
            Text(
              taskName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.indigo,
              ),
            ),
            const Text(
              '"',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ],
    );
  }
}