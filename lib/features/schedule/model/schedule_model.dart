import 'package:aturin_app/features/alarm/model/alarm.dart';
enum ActivityCategory {
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
      case ActivityCategory.akademik:
        return 'Akademik';
      case ActivityCategory.hiburan:
        return 'Hiburan';
      case ActivityCategory.pekerjaan:
        return 'Pekerjaan';
      case ActivityCategory.olahraga:
        return 'Olahraga';
      case ActivityCategory.sosial:
        return 'Sosial';
      case ActivityCategory.spiritual:
        return 'Spiritual';
      case ActivityCategory.pribadi:
        return 'Pribadi';
      case ActivityCategory.istirahat:
        return 'Istirahat';
    }
  }
}

extension ActivityCategoryExtension on ActivityCategory {
  String get name => displayName;
}

class ScheduleModel {
  final int activityId;
  final int userId;
  final int alarmId;
  final String activityTitle;
  final DateTime activityDate;
  final DateTime activityStartTime;
  final DateTime activityCompleteTime;  
  final ActivityCategory activityCategory;
  final AlarmModel? alarm;

  ScheduleModel({
    required this.activityId,
    required this.userId,
    required this.alarmId,
    required this.activityTitle,
    required this.activityDate,
    required this.activityStartTime,
    required this.activityCompleteTime,
    required this.activityCategory,
    this.alarm,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      activityId: json['activity_id'],
      userId: json['user_id'],
      alarmId: json['alarm_id'],
      activityTitle: json['activity_title'],      activityDate: DateTime.parse(json['activity_date']),
      activityStartTime: DateTime.parse(json['activity_start_time']),
      activityCompleteTime: DateTime.parse(json['activity_complete_time']),
      activityCategory: ActivityCategory.values.firstWhere(
        (category) => category.displayName == json['activity_category'],
      ),
      alarm: json['alarm'] != null ? AlarmModel.fromJson(json['alarm']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'user_id': userId,
      'alarm_id': alarmId,
      'activity_title': activityTitle,      'activity_date': activityDate.toIso8601String().split('T')[0],
      'activity_start_time': activityStartTime.toIso8601String(),
      'activity_complete_time': activityCompleteTime.toIso8601String(),
      'activity_category': activityCategory.displayName,
      'alarm': alarm?.toJson(),
    };
  }
  ScheduleModel copyWith({
    int? activityId,
    int? userId,
    int? alarmId,
    String? activityTitle,
    DateTime? activityDate,
    DateTime? activityStartTime,
    DateTime? activityCompleteTime,
    ActivityCategory? activityCategory,
    AlarmModel? alarm,
  }) {
    return ScheduleModel(
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      alarmId: alarmId ?? this.alarmId,
      activityTitle: activityTitle ?? this.activityTitle,
      activityDate: activityDate ?? this.activityDate,
      activityStartTime: activityStartTime ?? this.activityStartTime,
      activityCompleteTime: activityCompleteTime ?? this.activityCompleteTime,
      activityCategory: activityCategory ?? this.activityCategory,
      alarm: alarm ?? this.alarm,
    );
  }

  Duration get estimatedDuration {
    return activityCompleteTime.difference(activityStartTime);
  }

  String get formattedTimeRange {
    final startTime = '${activityStartTime.hour.toString().padLeft(2, '0')}:${activityStartTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${activityCompleteTime.hour.toString().padLeft(2, '0')}:${activityCompleteTime.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }
}