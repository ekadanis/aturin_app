import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:aturin_app/features/task/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:aturin_app/features/task/ui/screens/categories.dart';
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

  // Mengatur alarm untuk task
  Future<void> setAlarmForTask(Task task) async {
    if (!task.isAlarmEnabled || task.alarmDateTime == null || task.id == null) {
      debugPrint('Alarm tidak diaktifkan atau tanggalnya null atau id null');
      return;
    }

    // Periksa apakah alarm global diaktifkan
    final isGlobalEnabled = await isGlobalAlarmEnabled();
    if (!isGlobalEnabled) {
      debugPrint(
        'Alarm global dinonaktifkan, tidak mengatur alarm untuk: ${task.title}',
      );
      return;
    }

    try {
      await ensureInitialized();
      final now = DateTime.now();
      if (task.alarmDateTime!.isBefore(now)) {
        debugPrint(
          'Alarm waktu sudah lewat, tidak diatur: ${task.alarmDateTime}',
        );
        return;
      }

      try {
        final alarms = await Alarm.getAlarms();
        if (alarms.any((alarm) => alarm.id == task.id)) {
          await Alarm.stop(task.id!);
          debugPrint('Alarm lama dengan ID ${task.id} dihentikan');
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        debugPrint(
          'Tidak ada alarm sebelumnya dengan ID ${task.id} atau error: $e',
        );
      }

      final timeFormatter = DateFormat('HH:mm');

      // Buat pengaturan alarm
      final alarmSettings = AlarmSettings(
        id: task.id!,
        dateTime: task.alarmDateTime!,
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
          title: 'Aturin - Pengingat Tugas',
          body: '${task.title} (${getCategoryName(task.category)})',
          icon: 'mipmap/ic_launcher',
          iconColor: const Color.fromARGB(255, 255, 255, 255),
        ),
      );

      // Set alarm
      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint(
        'Alarm berhasil diatur untuk tugas: ${task.title} pada ${timeFormatter.format(task.alarmDateTime!)}',
      );
    } catch (e) {
      debugPrint('Error saat mengatur alarm: $e');
    }
  }

  // Menghapus alarm untuk task
  Future<void> removeAlarmForTask(int taskId) async {
    try {
      await ensureInitialized();

      final alarms = await Alarm.getAlarms();
      if (alarms.any((alarm) => alarm.id == taskId)) {
        await Alarm.stop(taskId);
        debugPrint('Alarm berhasil dihapus untuk taskId: $taskId');
      }
    } catch (e) {
      debugPrint('Error saat menghapus alarm: $e');
    }
  }

  // Update status alarm berdasarkan task
  Future<void> updateAlarmStatus(Task task) async {
    if (task.id == null) {
      debugPrint('Task ID null, tidak bisa update alarm');
      return;
    }
    try {
      await ensureInitialized();
      if (task.isAlarmEnabled && task.alarmDateTime != null) {
        await setAlarmForTask(task);
        debugPrint('Alarm diupdate untuk task ${task.id}: ${task.title}');
      } else {
        await removeAlarmForTask(task.id!);
        debugPrint(
          'Alarm dihapus karena dinonaktifkan untuk task ${task.id}: ${task.title}',
        );
      }
    } catch (e) {
      debugPrint('Error saat update status alarm: $e');
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
