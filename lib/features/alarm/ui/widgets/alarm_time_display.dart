import 'package:flutter/material.dart';

class AlarmTimeDisplay extends StatelessWidget {
  final String time;
  final String date;

  const AlarmTimeDisplay({
    Key? key,
    required this.time,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 80, // Larger font size
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}