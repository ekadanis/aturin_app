import 'package:flutter/material.dart';

class AlarmClockImage extends StatelessWidget {
  const AlarmClockImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Larger width
      height: 400, // Larger height
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Alarm.gif'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}