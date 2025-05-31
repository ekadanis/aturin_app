import 'package:aturin_app/features/jadwal/screens/add_aktivitas/validators/schedule_validator.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/category_selection_section.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/schedule_app_bar.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/date_selection_section.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/activity_form_section.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/time_selection_section.dart';
import 'package:aturin_app/core/widgets/alarm_configuration_section.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/jadwal/services/aktivitas_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class AddAktivitasPage extends StatefulWidget {
  final AktivitasModel? existingAktivitas;
  const AddAktivitasPage({super.key, this.existingAktivitas});

  @override
  _AddAktivitasPageState createState() => _AddAktivitasPageState();
}

class _AddAktivitasPageState extends State<AddAktivitasPage> {
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
    _initializeExistingAktivitas();
  }  void _initializeExistingAktivitas() async {
    final aktivitas = widget.existingAktivitas;
    print('DEBUG: _initializeExistingAktivitas called, existingAktivitas: ${aktivitas != null ? 'NOT NULL' : 'NULL'}');
    
    if (aktivitas != null) {
      activityTitle = aktivitas.activityTitle;
      selectedDate = aktivitas.activityDate;
      focusedDate = aktivitas.activityDate;
      startTime = TimeOfDay.fromDateTime(aktivitas.activityStartTime);
      endTime = TimeOfDay.fromDateTime(aktivitas.activityCompleteTime);
      
      // Cari kategori yang sesuai dengan aktivitas yang sedang diedit
      try {
        selectedCategory = categories.firstWhere(
          (c) => c.name == _getCategoryName(aktivitas.activityCategory),
        );
        print('DEBUG: Found matching category: ${selectedCategory?.name}');
      } catch (e) {
        // Jika kategori tidak ditemukan, biarkan selectedCategory null
        selectedCategory = null;
        print('DEBUG: Category not found, set to null');
      }      // Load alarm data via API if alarmId exists
      if (aktivitas.alarmId != null) {
        isAlarmEnabled = true;
        await _loadAlarmData(aktivitas.alarmId!);
      } else {
        isAlarmEnabled = false;
        alarmDateTime = null;
      }
    } else {
      // Untuk aktivitas baru, set default kategori ke "Akademik"
      selectedCategory = categories.firstWhere((c) => c.name == 'Akademik');
      print('DEBUG: New activity, selectedCategory set to default: ${selectedCategory?.name}');
    }
  }  Future<void> _loadAlarmData(int alarmId) async {
    try {
      final aktivitasService = Provider.of<AktivitasService>(context, listen: false);
      // Use API service to get all alarms and find by ID since backend only supports slug-based endpoints
      final allAlarms = await aktivitasService.alarmApiService.getAllAlarms();
      final alarmData = allAlarms.where((alarm) => alarm.id == alarmId).firstOrNull;
      
      if (alarmData != null && mounted) {
        setState(() {
          alarmDateTime = alarmData.alarmDateTime;
        });
        print('DEBUG: Loaded alarm data via API - alarmDateTime: ${alarmData.alarmDateTime}');
      }
    } catch (e) {
      print('DEBUG: Error loading alarm data via API: $e');
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

  // Get user ID from SharedPreferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId');
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
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
  }  void _saveSchedule() async {
    // Get user ID from SharedPreferences
    final userId = await _getUserId();
    if (userId == null) {
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: 'Error: User tidak teridentifikasi. Silakan login ulang.',
          isError: true,
        );
      }
      return;
    }    final startDateTime = DateTime(
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

    // Prepare alarm datetime if alarm is enabled
    DateTime? pickedAlarmDateTime;
    if (isAlarmEnabled && alarmDateTime != null) {
      pickedAlarmDateTime = alarmDateTime;
      print('DEBUG: Alarm enabled - pickedAlarmDateTime: $pickedAlarmDateTime');
    } else {
      print('DEBUG: Alarm disabled - isAlarmEnabled: $isAlarmEnabled, alarmDateTime: $alarmDateTime');
    }    final schedule = AktivitasModel(
      id: widget.existingAktivitas?.id,
      userId: userId, // Use dynamic user ID from SharedPreferences
      activityTitle: activityTitle.trim(),
      activityDate: selectedDate,activityStartTime: startDateTime,
      activityCompleteTime: endDateTime, // Use original end time
      activityCategory: _getCategoryEnum(selectedCategory!.name),
      alarmId: widget.existingAktivitas?.alarmId, // Keep existing alarmId for updates
      slug: widget.existingAktivitas?.slug, // Preserve existing slug for updates
    );

    try {
      final aktivitasService = Provider.of<AktivitasService>(context, listen: false);
      
      print('DEBUG: About to save aktivitas - isEdit: ${widget.existingAktivitas != null}, pickedAlarmDateTime: $pickedAlarmDateTime');
      
      if (widget.existingAktivitas != null) {
        // Update existing activity with new alarm time
        print('DEBUG: Updating existing aktivitas with ID: ${widget.existingAktivitas!.id}');
        await aktivitasService.updateAktivitas(schedule, pickedAlarmDateTime);
        print('DEBUG: Successfully updated aktivitas');
      } else {
        // Create new activity with alarm time
        print('DEBUG: Creating new aktivitas');
        final newId = await aktivitasService.addAktivitas(schedule, pickedAlarmDateTime);
        print('DEBUG: Successfully created aktivitas with ID: $newId');
      }      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: widget.existingAktivitas != null
              ? 'Aktivitas berhasil diperbarui'
              : 'Aktivitas berhasil ditambahkan',
          isError: false,
        );

        // Small delay to show the snackbar before navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.router.pushAndPopUntil(
              const AktivitasRoute(),
              predicate: (_) => false,
            );
          }
        });
      }
    } catch (e) {
      print('DEBUG: Error saving aktivitas: $e');
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: 'Gagal menyimpan aktivitas: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.router.pushAndPopUntil(
          const AktivitasRoute(),
          predicate: (_) => false,
        );
        return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: ScheduleAppBar(
          isEditMode: widget.existingAktivitas != null,
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