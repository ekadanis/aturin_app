import 'package:aturin_app/features/profile/models/user.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';

enum TaskStatus { 
  completed, 
  late, 
  today, 
  tomorrow, 
  upcoming 
}

enum TaskDatabaseStatus {
  belumSelesai,
  selesai, 
  terlambat;
  
  String get value {
    switch (this) {
      case TaskDatabaseStatus.belumSelesai:
        return 'belum_selesai';
      case TaskDatabaseStatus.selesai:
        return 'selesai';
      case TaskDatabaseStatus.terlambat:
        return 'terlambat';
    }
  }

  static TaskDatabaseStatus fromValue(String value) {
    switch (value) {
      case 'belum_selesai':
        return TaskDatabaseStatus.belumSelesai;
      case 'selesai':
        return TaskDatabaseStatus.selesai;
      case 'terlambat':
        return TaskDatabaseStatus.terlambat;
      default:
        return TaskDatabaseStatus.belumSelesai;
    }
  }
}

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
  final int? userId;
  final String title;
  final String? description;
  final DateTime deadline;
  final Duration estimatedDuration;
  final TaskDatabaseStatus taskStatus;
  final DateTime? completedAt;
  final String category;
  final int? alarmId;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final User? user;
  final AlarmModel? alarm;

  // Computed properties
  TaskStatus get status => calculateStatus(deadline);
  double get estimatedHours => estimatedDuration.inMinutes / 60;
  
  // Backward compatibility getters
  bool get isCompleted => taskStatus == TaskDatabaseStatus.selesai;
  bool get isAlarmEnabled => alarm != null && alarm!.alarmEnabled;
  DateTime? get alarmDateTime => alarm?.alarmDateTime;
  bool get isAlarmActive => isAlarmEnabled;
  bool get isDone => isCompleted;

  Task({
    this.id,
    this.userId,
    required this.title,
    this.description,
    required this.deadline,
    required this.estimatedDuration,
    TaskDatabaseStatus? taskStatus,
    this.completedAt,
    required this.category,
    this.alarmId,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.alarm,
  }) : taskStatus = taskStatus ?? TaskDatabaseStatus.belumSelesai;

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
  }  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'task_title': title,
      'task_description': description,
      'task_deadline': deadline.toUtc().toIso8601String(),
      'estimated_task_duration': estimatedDuration.inMinutes,
      'task_status': taskStatus.value,
      'task_completed_at': completedAt?.toIso8601String(),
      'task_category': category,
      'alarm_id': alarmId,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }  static Duration _parseDuration(dynamic value) {
    if (value is int) {
      return Duration(minutes: value);
    } else if (value is String && value.contains(':')) {
      final parts = value.split(':');
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return Duration(hours: hours, minutes: minutes);
    } else if (value is String) {
      return Duration(minutes: int.tryParse(value) ?? 0);
    }
    return Duration.zero;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['user_id'],
      title: map['task_title'] ?? '',
      description: map['task_description'],
      deadline: DateTime.parse(map['task_deadline']).toLocal(),
      estimatedDuration: _parseDuration(map['estimated_task_duration']),
      taskStatus: TaskDatabaseStatus.fromValue(map['task_status'] ?? 'belum_selesai'),
      completedAt: map['task_completed_at'] != null ? DateTime.parse(map['task_completed_at']) : null,
      category: map['task_category'] ?? 'akademik',
      alarmId: map['alarm_id'],
      slug: map['slug'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      user: null,
      alarm: map['alarm'] != null ? AlarmModel.fromJson(map['alarm']) : null,
    );
  }

  // Factory untuk membuat Task dari hasil JOIN query dengan relasi
  factory Task.fromMapWithRelations(Map<String, dynamic> map) {
    User? user;
    AlarmModel? alarm;
    
    // Buat User object jika data user ada
    if (map['user_name'] != null) {
      user = User(
        id: map['user_id'],
        name: map['user_name'] ?? '',
        email: map['user_email'] ?? '',
        avatar: map['user_avatar'] ?? '/assets/avatars/profile1.jpg',
        slug: map['user_slug'] ?? '',
      );
    }
    
    // Buat AlarmModel object jika data alarm ada
    if (map['alarm_date_time'] != null) {
      alarm = AlarmModel(
        id: map['alarm_id'],
        alarmDateTime: DateTime.parse(map['alarm_date_time']),
        alarmEnabled: map['alarm_enabled'] == 1,
        slug: map['alarm_slug'] ?? '',
      );
    }
    
    return Task(
      id: map['id'],
      userId: map['user_id'],
      title: map['task_title'] ?? '',
      description: map['task_description'],
      deadline: DateTime.parse(map['task_deadline']).toLocal(),
      estimatedDuration: Duration(minutes: map['estimated_task_duration'] ?? 0),
      taskStatus: TaskDatabaseStatus.fromValue(map['task_status'] ?? 'belum_selesai'),
      completedAt: map['task_completed_at'] != null ? DateTime.parse(map['task_completed_at']) : null,
      category: map['task_category'] ?? 'akademik',
      alarmId: map['alarm_id'],
      slug: map['slug'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      user: user,
      alarm: alarm,
    );
  }

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? deadline,
    Duration? estimatedDuration,
    TaskDatabaseStatus? taskStatus,
    DateTime? completedAt,
    String? category,
    int? alarmId,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    AlarmModel? alarm,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      taskStatus: taskStatus ?? this.taskStatus,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      alarmId: alarmId ?? this.alarmId,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      alarm: alarm ?? this.alarm,
    );  }
  factory Task.empty() {
    return Task(
      title: '',
      deadline: DateTime.now(),
      estimatedDuration: const Duration(minutes: 0),
      category: 'akademik',
    );
  }
}