import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:aturin_app/features/task/models/task.dart';
import 'package:intl/intl.dart';

class AlarmService {
  bool _initialized = false;

  // Memastikan alarm package sudah diinisialisasi
  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await Alarm.init();
      _initialized = true;
      debugPrint('Alarm package berhasil diinisialisasi');
    }
  }

  // Mengatur alarm untuk task
  Future<void> setAlarmForTask(Task task) async {
    if (!task.isAlarmEnabled || task.alarmDateTime == null || task.id == null) {
      debugPrint('Alarm tidak diaktifkan atau tanggalnya null atau id null');
      return;
    }
    
    try {
      // Pastikan alarm package sudah diinisialisasi
      await ensureInitialized();
      
      // Pastikan waktu alarm valid (tidak di masa lalu)
      final now = DateTime.now();
      if (task.alarmDateTime!.isBefore(now)) {
        debugPrint('Alarm waktu sudah lewat, tidak diatur: ${task.alarmDateTime}');
        return;
      }
      
      // Coba hentikan alarm dengan ID ini terlebih dahulu jika ada
      try {
        final alarms = await Alarm.getAlarms();
        if (alarms.any((alarm) => alarm.id == task.id)) {
          await Alarm.stop(task.id!);
          debugPrint('Alarm lama dengan ID ${task.id} dihentikan');
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        // Abaikan jika tidak ada alarm dengan ID ini
        debugPrint('Tidak ada alarm sebelumnya dengan ID ${task.id} atau error: $e');
      }

      // Format untuk alarm notifikasi
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
        allowAlarmOverlap: true,
        volumeSettings: VolumeSettings.staircaseFade(
          volume: null, // null berarti menggunakan volume sistem
          fadeSteps: [
            VolumeFadeStep(Duration.zero, 0.1),
            VolumeFadeStep(const Duration(seconds: 5), 0.3),
            VolumeFadeStep(const Duration(seconds: 10), 0.5),
            VolumeFadeStep(const Duration(seconds: 15), 0.7),
            VolumeFadeStep(const Duration(seconds: 20), 1.0),
          ],
          volumeEnforced: false, // false berarti menghormati volume sistem
        ),
        notificationSettings: NotificationSettings(
          title: 'Aturin - Pengingat Tugas',
          body: '${task.title} (${_getCategoryName(task.category)})',
          stopButton: 'Matikan',
          icon: 'mipmap/ic_launcher',
          iconColor: const Color(0xFF5263F3), // Warna primer Aturin
        ),
      );

      // Set alarm
      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('Alarm berhasil diatur untuk tugas: ${task.title} pada ${timeFormatter.format(task.alarmDateTime!)}');
      
    } catch (e) {
      debugPrint('Error saat mengatur alarm: $e');
    }
  }

  // Menghapus alarm untuk task
  Future<void> removeAlarmForTask(int taskId) async {
    try {
      // Pastikan alarm package sudah diinisialisasi
      await ensureInitialized();
      
      // Periksa apakah alarm dengan ID ini ada
      final alarms = await Alarm.getAlarms();
      if (alarms.any((alarm) => alarm.id == taskId)) {
        await Alarm.stop(taskId);
        debugPrint('Alarm berhasil dihapus untuk taskId: $taskId');
      }
    } catch (e) {
      debugPrint('Error saat menghapus alarm: $e');
    }
  }

  // Update alarm status berdasarkan task
  Future<void> updateAlarmStatus(Task task) async {
    if (task.id == null) {
      debugPrint('Task ID null, tidak bisa update alarm');
      return;
    }
    
    try {
      // Pastikan alarm package sudah diinisialisasi
      await ensureInitialized();
      
      if (task.isAlarmEnabled && task.alarmDateTime != null) {
        await setAlarmForTask(task);
        debugPrint('Alarm diupdate untuk task ${task.id}: ${task.title}');
      } else {
        await removeAlarmForTask(task.id!);
        debugPrint('Alarm dihapus karena dinonaktifkan untuk task ${task.id}: ${task.title}');
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

  // Mendapatkan nama kategori yang lebih user-friendly
  String _getCategoryName(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.$category',
        orElse: () => TaskCategory.akademik,
      );
      
      switch (taskCategory) {
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
    } catch (_) {
      return category;
    }
  }
}
