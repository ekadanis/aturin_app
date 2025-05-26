enum TaskStatus { completed, late, today, tomorrow, upcoming }

enum TaskCategory {
  akademik,
  hiburan,
  pekerjaan,
  olahraga,
  sosial,
  spiritual,
  pribadi,
  istirahat;
  
  String get displayName {
    switch (this) {
      case TaskCategory.akademik:
        return 'Akademik';
      case TaskCategory.hiburan:
        return 'Hiburan';
      case TaskCategory.pekerjaan:
        return 'Pekerjaan';
      case TaskCategory.olahraga:
        return 'Olahraga';
      case TaskCategory.sosial:
        return 'Sosial';
      case TaskCategory.spiritual:
        return 'Spiritual';
      case TaskCategory.pribadi:
        return 'Pribadi';
      case TaskCategory.istirahat:
        return 'Istirahat';
    }
  }
}

class Task {
  final int? id;
  final String title;
  final DateTime deadline;
  final Duration estimatedDuration;
  final String category;
  final bool isAlarmEnabled;
  final DateTime? alarmDateTime;
  final bool isDone;
  final TaskStatus status;
  final bool isCompleted;
  final bool isAlarmActive;
  final double estimatedHours;
  final DateTime? completedAt;
  final TaskStatus? previousStatus;

  Task({
    this.id,
    required this.title,
    required this.deadline,
    required this.estimatedDuration,
    required this.category,
    this.isAlarmEnabled = false,
    this.alarmDateTime,
    this.isDone = false,
    TaskStatus? status,
    bool? isCompleted,
    bool? isAlarmActive,
    double? estimatedHours,
    this.completedAt,
    this.previousStatus,
  }) : status = status ?? calculateStatus(deadline),
       isCompleted = isCompleted ?? isDone,
       isAlarmActive = isAlarmActive ?? isAlarmEnabled,
       estimatedHours = estimatedHours ?? (estimatedDuration.inMinutes / 60);

  static TaskStatus calculateStatus(DateTime deadline) {
  final now = DateTime.now();

  if (deadline.isBefore(now)) {
    return TaskStatus.late;
  }

  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);

  if (deadlineDate.isAtSameMomentAs(today)) {
    return TaskStatus.today;
  } else if (deadlineDate.isAtSameMomentAs(tomorrow)) {
    return TaskStatus.tomorrow;
  } else {
    return TaskStatus.upcoming;
  }
}

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
      'isCompleted': isCompleted ? 1 : 0,
      'status': status.name,
      'completedAt': completedAt?.toIso8601String(),
      'previousStatus': previousStatus?.name,
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
      isCompleted: map['isCompleted'] == 1, // ✅ ambil dari DB
      status:
          map['status'] != null
              ? TaskStatus.values.firstWhere(
                (e) => e.name == map['status'],
                orElse: () => calculateStatus(DateTime.parse(map['deadline'])),
              )
              : calculateStatus(DateTime.parse(map['deadline'])), // fallback
      completedAt:
          map['completedAt'] != null
              ? DateTime.parse(map['completedAt'])
              : null,
      previousStatus:
          map['previousStatus'] != null
              ? TaskStatus.values.firstWhere(
                (e) => e.name == map['previousStatus'],
                orElse: () => TaskStatus.today,
              )
              : null,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    DateTime? deadline,
    Duration? estimatedDuration,
    String? category,
    bool? isAlarmEnabled,
    DateTime? alarmDateTime,
    bool? isDone,
    TaskStatus? status,
    bool? isCompleted,
    bool? isAlarmActive,
    double? estimatedHours,
    DateTime? completedAt,
    TaskStatus? previousStatus,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      category: category ?? this.category,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      alarmDateTime: alarmDateTime ?? this.alarmDateTime,
      isDone: isDone ?? this.isDone,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      isAlarmActive: isAlarmActive ?? this.isAlarmActive,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      completedAt: completedAt ?? this.completedAt,
      previousStatus: previousStatus ?? this.previousStatus,
    );
  }
  
  // /// Creates an empty task instance for placeholder purposes
  factory Task.empty() {
    return Task(
      id: 0,
      title: '',
      deadline: DateTime.now(),
      estimatedDuration: const Duration(minutes: 0),
      category: '',
    );
  }
}
