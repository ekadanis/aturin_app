import 'package:aturin_app/features/home/models/task_model.dart';

class TaskService {
  static List<Task> tasks = [
    Task(
      category: TaskCategory.akademik,
      title: 'Laprak AI',
      timeRange: '9:00 AM – 12:00 PM',
      status: TaskStatus.selesai,
    ),
    Task(
      category: TaskCategory.akademik,
      title: 'Laprak AI',
      timeRange: '9:00 AM – 12:00 PM',
      status: TaskStatus.terlambat,
    ),
    Task(
      category: TaskCategory.akademik,
      title: 'Laprak AI',
      timeRange: '9:00 AM – 12:00 PM',
      status: TaskStatus.besok,
    ),
  ];
}
