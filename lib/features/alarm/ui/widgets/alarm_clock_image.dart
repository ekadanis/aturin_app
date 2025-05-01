import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AlarmClockImage extends StatelessWidget {
  const AlarmClockImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.w,
      height: 50.w,
      child: Image.asset(
        'assets/images/Alarm.gif',
        fit: BoxFit.contain,
      ),
    );
  }
}