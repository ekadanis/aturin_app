import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'features/jadwal/screens/detail_task/ui/widgets/task_detail_card.dart';
import 'features/task/model/task_model.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // atau 'en_US', dsb sesuai kebutuhan
  runApp(const TaskDetailCardDemo());
}

class TaskDetailCardDemo extends StatelessWidget {
  const TaskDetailCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data Task
    final task = Task(
      id: 1,
      title: '12345678901234567890',
      category: 'olahraga',
      deadline: DateTime.now().add(const Duration(days: 2)),
      estimatedDuration: const Duration(hours: 2, minutes: 30),
      description: 'Ini adalah deskripsi tugas contoh. asdsa dasdasdasd asdadadawd a',
      // tambahkan field lain jika perlu
    );

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: TaskDetailCard(task: task),
            ),
          ),
        );
      },
    );
  }
}