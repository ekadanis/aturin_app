import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:aturin_app/features/profile/models/user.dart';

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
        return 'Sosial';      case ActivityCategory.spiritual:
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

class AktivitasModel {
  final int? id;
  final int? userId;  // Foreign key to users table
  final String activityTitle;
  final DateTime activityDate;
  final DateTime activityStartTime;
  final DateTime activityCompleteTime;  
  final ActivityCategory activityCategory;
  final int? alarmId;  // Foreign key to alarms table
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final User? user;
  final AlarmModel? alarm;

  AktivitasModel({
    this.id,
    this.userId,
    required this.activityTitle,
    required this.activityDate,
    required this.activityStartTime,
    required this.activityCompleteTime,
    required this.activityCategory,
    this.alarmId,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.alarm,
  });

  factory AktivitasModel.fromJson(Map<String, dynamic> json) {
    return AktivitasModel(
      id: json['id'],
      userId: json['user_id'],
      activityTitle: json['activity_title'],
      activityDate: DateTime.parse(json['activity_date']),
      activityStartTime: DateTime.parse(json['activity_start_time']),
      activityCompleteTime: DateTime.parse(json['activity_complete_time']),
      activityCategory: ActivityCategory.values.firstWhere(
        (category) => category.displayName == json['activity_category'],
      ),
      alarmId: json['alarm_id'],
      slug: json['slug'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      alarm: json['alarm'] != null ? AlarmModel.fromJson(json['alarm']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_title': activityTitle,
      'activity_date': activityDate.toIso8601String().split('T')[0],
      'activity_start_time': activityStartTime.toIso8601String(),
      'activity_complete_time': activityCompleteTime.toIso8601String(),
      'activity_category': activityCategory.displayName,
      'alarm_id': alarmId,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'alarm': alarm?.toJson(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity_title': activityTitle,
      'activity_date': activityDate.toIso8601String().split('T')[0],
      'activity_start_time': activityStartTime.toIso8601String(),
      'activity_complete_time': activityCompleteTime.toIso8601String(),
      'activity_category': activityCategory.displayName,
      'alarm_id': alarmId,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AktivitasModel.fromMap(Map<String, dynamic> map) {
    AlarmModel? alarm;
    if (map['alarm_date_time'] != null) {
      alarm = AlarmModel(
        id: map['alarm_id'],
        alarmDateTime: DateTime.parse(map['alarm_date_time']),
        alarmEnabled: map['alarm_enabled'] == 1 || map['alarm_enabled'] == true,
        slug: map['alarm_slug'] ?? '',
        createdAt: map['alarm_created_at'] != null ? DateTime.tryParse(map['alarm_created_at']) : null,
        updatedAt: map['alarm_updated_at'] != null ? DateTime.tryParse(map['alarm_updated_at']) : null,
      );
    }
    return AktivitasModel(
      id: map['id'],
      userId: map['user_id'],
      activityTitle: map['activity_title'] ?? '',
      activityDate: DateTime.parse(map['activity_date']),
      activityStartTime: DateTime.parse(map['activity_start_time']),
      activityCompleteTime: DateTime.parse(map['activity_complete_time']),
      activityCategory: ActivityCategory.values.firstWhere(
        (category) => category.displayName == map['activity_category'],
        orElse: () => ActivityCategory.akademik,
      ),
      alarmId: map['alarm_id'],
      slug: map['slug'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      alarm: alarm,
    );
  }

  AktivitasModel copyWith({
    int? id,
    int? userId,
    String? activityTitle,
    DateTime? activityDate,
    DateTime? activityStartTime,
    DateTime? activityCompleteTime,
    ActivityCategory? activityCategory,
    int? alarmId,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    AlarmModel? alarm,
    User? user,
  }) {
    return AktivitasModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityTitle: activityTitle ?? this.activityTitle,
      activityDate: activityDate ?? this.activityDate,
      activityStartTime: activityStartTime ?? this.activityStartTime,
      activityCompleteTime: activityCompleteTime ?? this.activityCompleteTime,
      activityCategory: activityCategory ?? this.activityCategory,
      alarmId: alarmId ?? this.alarmId,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      alarm: alarm ?? this.alarm,
      user: user ?? this.user,
    );
  }

  // Backward compatibility getter
  int? get activityId => id;

  Duration get estimatedDuration {
    return activityCompleteTime.difference(activityStartTime);
  }

  String get formattedTimeRange {
    final startTime = '${activityStartTime.hour.toString().padLeft(2, '0')}:${activityStartTime.minute.toString().padLeft(2, '0')}';
    final endTime = '${activityCompleteTime.hour.toString().padLeft(2, '0')}:${activityCompleteTime.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }
}
