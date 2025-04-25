enum TaskStatus { selesai, terlambat, besok }
enum TaskCategory { akademik, hiburan, pekerjaan, olahraga, sosial, spiritual, pribadi, istirahat }

class Task {
  final TaskCategory category; 
  final String title;
  final String timeRange;
  final TaskStatus status;

  Task({
    required this.category,
    required this.title,
    required this.timeRange,
    required this.status,
  });
}
