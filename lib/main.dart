// lib/main.dart
import 'package:flutter/material.dart';
import 'package:aturin_app/features/alarm/ui/screens/alarm_ring_screen.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Alarm App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sample alarm data
  final Alarm _currentAlarm = Alarm(
    time: "06:00",
    date: "Fri, 3 Dec",
    taskName: "Tugas Praktikum AI",
    category: "Hiburan",
  );

  bool _showAlarmScreen = true;

  void _toggleAlarmScreen() {
    setState(() {
      _showAlarmScreen = !_showAlarmScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAlarmScreen) {
      return AlarmRingScreen(
        time: _currentAlarm.time,
        date: _currentAlarm.date,
        taskName: _currentAlarm.taskName,
        category: _currentAlarm.category,
      );
    }
    
    // Main app screen when alarm is not active
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Your next alarm:'),
            Text(
              _currentAlarm.time,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(_currentAlarm.date),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleAlarmScreen,
              child: const Text('Test Alarm Screen'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new alarm functionality would go here
        },
        tooltip: 'Add Alarm',
        child: const Icon(Icons.add),
      ),
    );
  }
}