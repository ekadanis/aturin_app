import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:intl/intl.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmService {
  bool _initialized = false;
  static const String _globalAlarmKey = 'global_alarm_enabled';

  // Memastikan alarm package sudah diinisialisasi
  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await Alarm.init();
      _initialized = true;
      debugPrint('Alarm package berhasil diinisialisasi');
    }
  }

  // Memeriksa apakah alarm global diaktifkan
  Future<bool> isGlobalAlarmEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_globalAlarmKey) ?? true;
  }

  // Mengatur status alarm global
  Future<void> setGlobalAlarmEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_globalAlarmKey, value);
    debugPrint('Status alarm global diatur ke: $value');
  }


  // Mengatur alarm untuk aktivitas (umum, bukan hanya task)
  Future<void> setAlarm(
    int id,
    DateTime dateTime,
    String title,
    String body,
  ) async {
    await ensureInitialized();
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      debugPrint('Alarm waktu sudah lewat, tidak diatur: $dateTime');
      return;
    }

    try {
      final alarms = await Alarm.getAlarms();
      if (alarms.any((alarm) => alarm.id == id)) {
        await Alarm.stop(id);
        debugPrint('Alarm lama dengan ID $id dihentikan');
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Tidak ada alarm sebelumnya dengan ID $id atau error: $e');
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: 'assets/audio/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isAndroid,
      androidFullScreenIntent: true,
      allowAlarmOverlap: false,
      volumeSettings: VolumeSettings.staircaseFade(
        volume: null,
        fadeSteps: [VolumeFadeStep(Duration.zero, 0.1)],
        volumeEnforced: false,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        icon: 'mipmap/ic_launcher',
        iconColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('Alarm berhasil diatur untuk aktivitas: $title pada $dateTime');
  }

  // Menghapus alarm berdasarkan ID (untuk aktivitas dan task)
  Future<void> cancelAlarm(int alarmId) async {
    try {
      await ensureInitialized();
      
      final alarms = await Alarm.getAlarms();
      if (alarms.any((alarm) => alarm.id == alarmId)) {
        await Alarm.stop(alarmId);
        debugPrint('Alarm berhasil dihapus untuk ID: $alarmId');
      } else {
        debugPrint('Tidak ada alarm aktif dengan ID: $alarmId');
      }
    } catch (e) {
      debugPrint('Error saat menghapus alarm: $e');
    }
  }

  // Mendapatkan semua alarm yang aktif
  Future<List<AlarmSettings>> getActiveAlarms() async {
    try {
      await ensureInitialized();
      return await Alarm.getAlarms();
    } catch (e) {
      debugPrint('Error saat mendapatkan alarm aktif: $e');
      return [];
    }
  }

  // Cek apakah alarm tertentu aktif
  Future<bool> hasAlarm(int taskId) async {
    try {
      await ensureInitialized();
      final alarms = await Alarm.getAlarms();
      return alarms.any((alarm) => alarm.id == taskId);
    } catch (e) {
      debugPrint('Error saat cek status alarm: $e');
      return false;
    }
  }

  // Helper method untuk mendapatkan nama kategori dalam format yang benar
  String getCategoryName(String category) {
    try {
      for (var validCategory in [
        "Akademik",
        "Hiburan",
        "Pekerjaan",
        "Olahraga",
        "Sosial",
        "Spiritual",
        "Pribadi",
        "Istirahat",
      ]) {
        if (category == validCategory) {
          return category;
        }
      }
      if (category.contains(".")) {
        final extractedCategory = category.split(".").last.toLowerCase();

        switch (extractedCategory) {
          case "akademik":
            return "Akademik";
          case "hiburan":
            return "Hiburan";
          case "pekerjaan":
            return "Pekerjaan";
          case "olahraga":
            return "Olahraga";
          case "sosial":
            return "Sosial";
          case "spiritual":
            return "Spiritual";
          case "pribadi":
            return "Pribadi";
          case "istirahat":
            return "Istirahat";
          default:
            break;
        }
      }

      try {
        final taskCategory = TaskCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == category.toLowerCase(),
          orElse: () => TaskCategory.akademik,
        );

        switch (taskCategory) {
          case TaskCategory.akademik:
            return "Akademik";
          case TaskCategory.hiburan:
            return "Hiburan";
          case TaskCategory.pekerjaan:
            return "Pekerjaan";
          case TaskCategory.olahraga:
            return "Olahraga";
          case TaskCategory.sosial:
            return "Sosial";
          case TaskCategory.spiritual:
            return "Spiritual";
          case TaskCategory.pribadi:
            return "Pribadi";
          case TaskCategory.istirahat:
            return "Istirahat";
        }
      } catch (_) {}

      return category;
    } catch (_) {
      return category;
    }
  }

  // Helper untuk mendapatkan CategoryOption dari string kategori
  CategoryOption getCategoryOption(String category) {
    try {
      for (var option in categories) {
        if (option.name == category) {
          return option;
        }
      }

      final categoryName = getCategoryName(category);

      for (var option in categories) {
        if (option.name == categoryName) {
          return option;
        }
      }

      return categories[0];
    } catch (_) {
      return categories[0];
    }
  }
}
