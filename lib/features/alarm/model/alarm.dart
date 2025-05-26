class AlarmModel {
  final int alarmId;
  final DateTime alarmDateTime;
  final bool alarmEnabled;

  AlarmModel({
    required this.alarmId,
    required this.alarmDateTime,
    required this.alarmEnabled,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      alarmId: json['alarm_id'],
      alarmDateTime: DateTime.parse(json['alarm_date_time']),
      alarmEnabled: json['alarm_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alarm_id': alarmId,
      'alarm_date_time': alarmDateTime.toIso8601String(),
      'alarm_enabled': alarmEnabled,
    };
  }

  AlarmModel copyWith({
    int? alarmId,
    DateTime? alarmDateTime,
    bool? alarmEnabled,
  }) {
    return AlarmModel(
      alarmId: alarmId ?? this.alarmId,
      alarmDateTime: alarmDateTime ?? this.alarmDateTime,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
    );
  }
}