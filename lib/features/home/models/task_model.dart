enum TaskStatus { selesai, belumDikerjakan }
enum TaskCategory { akademik, hiburan, pekerjaan, olahraga, sosial, spiritual, pribadi, istirahat }

class Task {
  final TaskCategory category; 
  final String title;
  final String timeRange;
  final TaskStatus status;
  final DateTime deadline;
  final bool isAlarmEnabled;
  final bool isLateCompletion;

  Task({
    required this.category,
    required this.title,
    required this.timeRange,
    required this.status,
    required this.deadline,
    this.isAlarmEnabled = false,
    this.isLateCompletion = false,
  });
}
