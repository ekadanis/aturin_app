import 'package:flutter/material.dart';

class EmptyTask extends StatelessWidget {
  const EmptyTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/https___lottiefiles.com_animations_no-data-bt8EDsKmcr.gif',
          height: 150,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 8),
        const Text(
          'Yuk, tambahkan tugas pertama kamu!',
          style: TextStyle(color: Colors.blueAccent),
        ),
      ],
    );
  }
}