class AlarmModel {
  final int? id;
  final DateTime alarmDateTime;
  final bool alarmEnabled;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  AlarmModel({
    this.id,
    required this.alarmDateTime,
    required this.alarmEnabled,
    required this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      alarmDateTime: json['alarm_date_time'] != null ? DateTime.parse(json['alarm_date_time']) : DateTime.now(),
      alarmEnabled: json['is_alarm_enabled'] == 1 || json['is_alarm_enabled'] == true || json['alarm_enabled'] == 1 || json['alarm_enabled'] == true,
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alarm_date_time': alarmDateTime.toIso8601String(),
      'alarm_enabled': alarmEnabled,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alarm_date_time': alarmDateTime.toIso8601String(),
      'alarm_enabled': alarmEnabled ? 1 : 0,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'],
      alarmDateTime: DateTime.parse(map['alarm_date_time']),
      alarmEnabled: map['alarm_enabled'] == 1,
      slug: map['slug'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  AlarmModel copyWith({
    int? id,
    DateTime? alarmDateTime,
    bool? alarmEnabled,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      alarmDateTime: alarmDateTime ?? this.alarmDateTime,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Backward compatibility getter
  int get alarmId => id ?? 0;
}