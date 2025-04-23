class Task {
  final int? id;
  final String title;
  final DateTime deadline;
  final Duration estimatedDuration;
  final String category;
  final bool isAlarmEnabled;
  final DateTime? alarmDateTime;
  final bool isDone;

  Task({
    this.id,
    required this.title,
    required this.deadline,
    required this.estimatedDuration,
    required this.category,
    this.isAlarmEnabled = false,
    this.alarmDateTime,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(),
      'estimatedDuration': estimatedDuration.inMinutes,
      'category': category,
      'isAlarmEnabled': isAlarmEnabled ? 1 : 0,
      'alarmDateTime': alarmDateTime?.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      deadline: DateTime.parse(map['deadline']),
      estimatedDuration: Duration(minutes: map['estimatedDuration']),
      category: map['category'],
      isAlarmEnabled: map['isAlarmEnabled'] == 1,
      alarmDateTime:
          map['alarmDateTime'] != null
              ? DateTime.parse(map['alarmDateTime'])
              : null,
      isDone: map['isDone'] == 1,
    );
  }
}
