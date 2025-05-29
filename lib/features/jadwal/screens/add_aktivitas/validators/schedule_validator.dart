import 'package:flutter/material.dart';

class ValidationResult {
  final bool isValid;
  final Map<String, String?> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}

class ScheduleValidator {
  static const int maxTitleLength = 20;

  ValidationResult validateSchedule({
    required String title,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required String? category,
  }) {
    Map<String, String?> errors = {};

    // Validate title
    final titleError = _validateTitle(title);
    if (titleError != null) {
      errors['title'] = titleError;
    }

    // Validate start time
    final startTimeError = _validateStartTime(startTime);
    if (startTimeError != null) {
      errors['startTime'] = startTimeError;
    }

    // Validate end time
    final endTimeError = _validateEndTime(endTime);
    if (endTimeError != null) {
      errors['endTime'] = endTimeError;
    }

    // Validate time sequence
    if (startTime != null && endTime != null) {
      final timeSequenceError = _validateTimeSequence(startTime, endTime);
      if (timeSequenceError != null) {
        errors['endTime'] = timeSequenceError;
      }
    }

    // Validate category
    final categoryError = _validateCategory(category);
    if (categoryError != null) {
      errors['category'] = categoryError;
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  String? _validateTitle(String title) {
    final trimmedTitle = title.trim();
    
    if (trimmedTitle.isEmpty) {
      return 'Nama aktivitas harus diisi';
    }
    
    if (trimmedTitle.length > maxTitleLength) {
      return 'Nama aktivitas maksimal $maxTitleLength karakter';
    }
    
    return null;
  }

  String? _validateStartTime(TimeOfDay? startTime) {
    if (startTime == null) {
      return 'Pilih waktu mulai';
    }
    return null;
  }

  String? _validateEndTime(TimeOfDay? endTime) {
    if (endTime == null) {
      return 'Pilih waktu selesai';
    }
    return null;
  }

  String? _validateTimeSequence(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    if (endMinutes <= startMinutes) {
      return 'Waktu selesai harus setelah waktu mulai';
    }
    
    return null;
  }

  String? _validateCategory(String? category) {
    if (category == null || category.isEmpty) {
      return 'Pilih kategori';
    }
    return null;
  }

  // Additional validation methods for specific use cases
  bool isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes > startMinutes;
  }

  bool isValidTitle(String title) {
    final trimmedTitle = title.trim();
    return trimmedTitle.isNotEmpty && trimmedTitle.length <= maxTitleLength;
  }

  int getRemainingCharacters(String title) {
    return maxTitleLength - title.length;
  }

  bool isCharacterLimitExceeded(String title) {
    return title.length > maxTitleLength;
  }
}