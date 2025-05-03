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
    // Menggunakan MediaQuery alih-alih sizer untuk menghindari LateInitializationError
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: screenWidth * 0.18, // Setara dengan 18.w
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
        SizedBox(height: screenWidth * 0.01), // Setara dengan 0.5.h
        Text(
          date,
          style: TextStyle(
            fontSize: screenWidth * 0.04, // Setara dengan 4.w
            color: Colors.black87,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}