import 'package:aturin_app/features/schedule/screens/add_schedule/validators/schedule_validator.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/category_selection_section.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/schedule_app_bar.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/date_selection_section.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/activity_form_section.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/time_selection_section.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/alarm_configuration_section.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import 'package:aturin_app/features/schedule/model/schedule_model.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';

@RoutePage()
class AddSchedulePage extends StatefulWidget {
  final ScheduleModel? existingSchedule;
  const AddSchedulePage({super.key, this.existingSchedule});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  // Form data
  String activityTitle = '';
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  CategoryOption? selectedCategory;
  bool isAlarmEnabled = false;
  DateTime? alarmDateTime;

  // Validation errors
  Map<String, String?> errors = {};

  @override
  void initState() {
    super.initState();
    _initializeExistingSchedule();
  }

  void _initializeExistingSchedule() {
    final schedule = widget.existingSchedule;
    if (schedule != null) {
      activityTitle = schedule.activityTitle;
      selectedDate = schedule.activityDate;
      focusedDate = schedule.activityDate;
      startTime = TimeOfDay.fromDateTime(schedule.activityStartTime);
      endTime = TimeOfDay.fromDateTime(schedule.activityCompleteTime);
      selectedCategory = categories.firstWhere(
        (c) => c.name == _getCategoryName(schedule.activityCategory),
        orElse: () => categories.first,
      );
      isAlarmEnabled = schedule.alarm?.alarmEnabled ?? false;
      alarmDateTime = schedule.alarm?.alarmDateTime;
    }
  }

  String _getCategoryName(ActivityCategory category) {
    return category.displayName;
  }

  ActivityCategory _getCategoryEnum(String categoryName) {
    return ActivityCategory.values.firstWhere(
      (category) => category.displayName == categoryName,
      orElse: () => ActivityCategory.akademik,
    );
  }

  void _validateAndSave() {
    final validator = ScheduleValidator();
    final validationResult = validator.validateSchedule(
      title: activityTitle,
      startTime: startTime,
      endTime: endTime,
      category: selectedCategory?.name,
    );

    setState(() {
      errors = validationResult.errors;
    });

    if (validationResult.isValid) {
      _saveSchedule();
    }
  }

  void _saveSchedule() {
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime!.hour,
      endTime!.minute,
    );

    final schedule = ScheduleModel(
      activityId: widget.existingSchedule?.activityId ?? DateTime.now().millisecondsSinceEpoch,
      userId: 1,
      alarmId: isAlarmEnabled ? DateTime.now().millisecondsSinceEpoch : 0,
      activityTitle: activityTitle.trim(),
      activityDate: selectedDate,
      activityStartTime: startDateTime,
      activityCompleteTime: endDateTime,
      activityCategory: _getCategoryEnum(selectedCategory!.name),
      alarm: isAlarmEnabled ? AlarmModel(
        alarmId: DateTime.now().millisecondsSinceEpoch,
        alarmDateTime: alarmDateTime ?? startDateTime.subtract(const Duration(minutes: 15)),
        alarmEnabled: true,
      ) : null,
    );

    if (mounted) {
      showCustomTopSnackbar(
        context: context,
        message: widget.existingSchedule != null 
            ? 'Aktivitas berhasil diperbarui'
            : 'Aktivitas berhasil ditambahkan',
        isError: false,
      );

      Future.delayed(const Duration(seconds: 1), () {
        context.router.pushAndPopUntil(
          const ScheduleRoute(),
          predicate: (_) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.router.pushAndPopUntil(
          const ScheduleRoute(),
          predicate: (_) => false,
        );
        return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: ScheduleAppBar(
          isEditMode: widget.existingSchedule != null,
          onSave: _validateAndSave,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateSelectionSection(
                selectedDate: selectedDate,
                focusedDate: focusedDate,
                calendarFormat: calendarFormat,
                onDateSelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                    focusedDate = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    focusedDate = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    calendarFormat = format;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActivityFormSection(
                      initialTitle: activityTitle,
                      titleError: errors['title'],
                      onTitleChanged: (value) {
                        setState(() {
                          activityTitle = value;
                          errors.remove('title');
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TimeSelectionSection(
                      startTime: startTime,
                      endTime: endTime,
                      selectedDate: selectedDate,
                      startTimeError: errors['startTime'],
                      endTimeError: errors['endTime'],
                      onStartTimeChanged: (time) {
                        setState(() {
                          startTime = time;
                          errors.remove('startTime');
                          _updateAlarmTimeIfNeeded();
                          _autoAdjustEndTime(time);
                        });
                      },
                      onEndTimeChanged: (time) {
                        setState(() {
                          endTime = time;
                          errors.remove('endTime');
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    CategorySelectionSection(
                      selectedCategory: selectedCategory,
                      categoryError: errors['category'],
                      onCategoryChanged: (category) {
                        setState(() {
                          selectedCategory = category;
                          errors.remove('category');
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    AlarmConfigurationSection(
                      isEnabled: isAlarmEnabled,
                      alarmDateTime: alarmDateTime,
                      selectedDate: selectedDate,
                      startTime: startTime,
                      onToggle: (value) {
                        setState(() {
                          isAlarmEnabled = value;
                          if (value && alarmDateTime == null && startTime != null) {
                            _updateAlarmTimeIfNeeded();
                          } else if (!value) {
                            alarmDateTime = null;
                          }
                        });
                      },
                      onAlarmTimeChanged: (dateTime) {
                        setState(() {
                          alarmDateTime = dateTime;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAlarmTimeIfNeeded() {
    if (isAlarmEnabled && alarmDateTime == null && startTime != null) {
      final startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime!.hour,
        startTime!.minute,
      );
      alarmDateTime = startDateTime.subtract(const Duration(minutes: 15));
    }
  }

  void _autoAdjustEndTime(TimeOfDay newStartTime) {
    if (endTime != null) {
      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;
      
      if (endMinutes <= startMinutes) {
        final newEndTime = TimeOfDay(
          hour: (newStartTime.hour + 1) % 24,
          minute: newStartTime.minute,
        );
        endTime = newEndTime;
        errors.remove('endTime');
      }
    }
  }
}