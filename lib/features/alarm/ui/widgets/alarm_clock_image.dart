import 'package:flutter/material.dart';

class AlarmClockImage extends StatelessWidget {
  const AlarmClockImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan MediaQuery alih-alih sizer untuk menghindari LateInitializationError
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SizedBox(
      // 90% dari lebar layar
      width: screenWidth * 0.9,
      // 50% dari lebar layar
      height: screenWidth * 0.5, 
      child: Image.asset(
        'assets/images/Alarm.gif',
        fit: BoxFit.contain,
      ),
    );
  }
}