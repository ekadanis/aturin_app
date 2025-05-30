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
        return 'Sosial';
      case ActivityCategory.spiritual:
        return 'Spiritual';
      case ActivityCategory.pribadi:
        return 'Pribadi';
      case ActivityCategory.istirahat:
        return 'Istirahat';
    }
  }
    // For API compatibility - returns lowercase enum name
  String get apiName {
    switch (this) {
      case ActivityCategory.akademik:
        return 'akademik';
      case ActivityCategory.hiburan:
        return 'hiburan';
      case ActivityCategory.pekerjaan:
        return 'pekerjaan';
      case ActivityCategory.olahraga:
        return 'olahraga';
      case ActivityCategory.sosial:
        return 'sosial';
      case ActivityCategory.spiritual:
        return 'spiritual';
      case ActivityCategory.pribadi:
        return 'pribadi';
      case ActivityCategory.istirahat:
        return 'istirahat';
    }
  }
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
  });  factory AktivitasModel.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('DEBUG: Parsing JSON data: $json');
    
    return AktivitasModel(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      userId: json['user_id'] is String ? int.tryParse(json['user_id']) : json['user_id'],
      activityTitle: json['activity_title'] ?? '',
      activityDate: DateTime.parse(json['activity_date']),
      activityStartTime: _parseDateTime(json['activity_date'], json['activity_start_time']),
      activityCompleteTime: _parseDateTime(json['activity_date'], json['activity_complete_time']),
      activityCategory: _parseActivityCategory(json['activity_category']),
      alarmId: json['alarm_id'] is String ? int.tryParse(json['alarm_id']) : json['alarm_id'],
      slug: json['slug'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      alarm: json['alarm'] != null ? AlarmModel.fromJson(json['alarm']) : null,
    );
  }  // Helper method to parse datetime from date and time strings
  static DateTime _parseDateTime(String date, String time) {
    try {
      // Try to parse as full ISO8601 datetime first
      return DateTime.parse(time);
    } catch (e) {
      // If that fails, assume it's H:i or H:i:s format and combine with date
      try {
        final timeParts = time.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          // Ignore seconds if present (timeParts[2])
          final dateTime = DateTime.parse(date);
          return DateTime(dateTime.year, dateTime.month, dateTime.day, hour, minute);
        } else {
          throw FormatException('Invalid time format: $time');
        }
      } catch (e2) {
        print('DEBUG: Error parsing time "$time": $e2');
        throw FormatException('Invalid date format: $time');
      }
    }
  }

  // Helper method to parse activity category safely
  static ActivityCategory _parseActivityCategory(dynamic categoryValue) {
    if (categoryValue == null) return ActivityCategory.akademik;
    
    final categoryString = categoryValue.toString().toLowerCase();
    print('DEBUG: Parsing category: "$categoryString"');
    
    // Try to match by apiName first (lowercase enum name)
    for (final category in ActivityCategory.values) {
      if (category.apiName == categoryString) {
        print('DEBUG: Found category by apiName: ${category.apiName}');
        return category;
      }
    }
    
    // Try to match by displayName
    for (final category in ActivityCategory.values) {
      if (category.displayName.toLowerCase() == categoryString) {
        print('DEBUG: Found category by displayName: ${category.displayName}');
        return category;
      }
    }
    
    print('DEBUG: Category not found, using default: akademik');
    return ActivityCategory.akademik;
  }Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_title': activityTitle,
      'activity_date': activityDate.toIso8601String().split('T')[0],
      'activity_start_time': '${activityStartTime.hour.toString().padLeft(2, '0')}:${activityStartTime.minute.toString().padLeft(2, '0')}',
      'activity_complete_time': '${activityCompleteTime.hour.toString().padLeft(2, '0')}:${activityCompleteTime.minute.toString().padLeft(2, '0')}',
      'activity_category': activityCategory.apiName,
      'alarm_id': alarmId,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'alarm': alarm?.toJson(),
    };
  }  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity_title': activityTitle,
      'activity_date': activityDate.toIso8601String().split('T')[0],
      'activity_start_time': '${activityStartTime.hour.toString().padLeft(2, '0')}:${activityStartTime.minute.toString().padLeft(2, '0')}',
      'activity_complete_time': '${activityCompleteTime.hour.toString().padLeft(2, '0')}:${activityCompleteTime.minute.toString().padLeft(2, '0')}',
      'activity_category': activityCategory.apiName,
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
    }    return AktivitasModel(
      id: map['id'],
      userId: map['user_id'],
      activityTitle: map['activity_title'] ?? '',
      activityDate: DateTime.parse(map['activity_date']),
      activityStartTime: _parseDateTime(map['activity_date'], map['activity_start_time']),
      activityCompleteTime: _parseDateTime(map['activity_date'], map['activity_complete_time']),
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
