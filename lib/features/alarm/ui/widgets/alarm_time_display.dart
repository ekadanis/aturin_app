import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
          style: TextStyle(
            fontSize: 18.w,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          date,
          style: TextStyle(
            fontSize: 4.w,
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