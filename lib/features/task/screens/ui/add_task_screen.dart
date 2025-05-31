import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/task/screens/widgets/task_title_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import '../../model/task_model.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import '../widgets/deadline_picker_bottom.dart';
import '../widgets/duration_picker_bottom.dart';
import 'category_picker_screen.dart';
import '../../../jadwal/screens/add_aktivitas/ui/alarm_picker_screen.dart';
import '../../../../../../routers/app_router.dart';
import 'package:aturin_app/core/widgets/field_tile.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';
import 'package:aturin_app/core/services/api/task/task_service.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:aturin_app/features/alarm/services/alarm_service.dart';

@RoutePage()
class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _deadlineError;
  String? _durationError;
  String? _categoryError;
  String? _alarmDateTimeError;
  String? _alarmToggleError;

  DateTime? _deadline;
  Duration? _estimatedDuration;
  CategoryOption? _selectedCategory;
  bool _isAlarmEnabled = false;
  DateTime? _alarmDateTime;

  // Store the selected alarm option locally (not in the Task model)
  String? _selectedAlarmOption;

  // Tambahkan di atas
  DateTime? _customAlarmDateTime;

  final TaskService _taskService = TaskService();
  final AlarmApiService _alarmApiService = AlarmApiService();
  final AlarmService _localAlarmService = AlarmService();

  bool _alarmLoading = false;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _deadline = task.deadline;
      _estimatedDuration = task.estimatedDuration;
      // Normalisasi pencarian kategori (case-insensitive, trim)
      final foundCategory = categories.where((c) => c.name.toLowerCase().trim() == task.category.toLowerCase().trim());
      _selectedCategory = foundCategory.isNotEmpty ? foundCategory.first : null;
      if (task.alarmId != null) {
        _isAlarmEnabled = true;
        _alarmLoading = true;
        _fetchAlarmAndSet(task.alarmId!).then((_) {
          setState(() {
            _alarmLoading = false;
          });
        });
      } else {
        _isAlarmEnabled = false;
        _alarmDateTime = null;
      }
    } else {
      final foundCategory = categories.where((c) => c.name.toLowerCase().trim() == 'akademik');
      _selectedCategory = foundCategory.isNotEmpty ? foundCategory.first : (categories.isNotEmpty ? categories.first : null);
      if (_deadline != null && _alarmDateTime != null) {
        _selectedAlarmOption = _determineAlarmOption(
          _deadline!,
          _alarmDateTime!,
        );
      }
    }
    _updateWordCount();
    _updateDescriptionWordCount();
    _titleController.addListener(_updateWordCount);
    _descriptionController.addListener(_updateDescriptionWordCount);
  }

  Future<void> _fetchAlarmAndSet(int alarmId) async {
    try {
      final alarm = await _alarmApiService.getAlarmById(alarmId);
      if (alarm != null) {
        setState(() {
          _alarmDateTime = alarm.alarmDateTime;
          _selectedAlarmOption = _determineAlarmOption(_deadline ?? alarm.alarmDateTime, alarm.alarmDateTime);
          _customAlarmDateTime = alarm.alarmDateTime;
        });
        // Sinkron ke alarm lokal
        await _localAlarmService.setAlarm(
          alarm.id!,
          alarm.alarmDateTime,
          _titleController.text.trim(),
          'Tugas: ${_titleController.text.trim()} sudah waktunya!'
        );
      }
    } catch (e) {
      debugPrint('Gagal mengambil alarm: $e');
    }
  }

  Future<void> _updateAlarmBackendAndLocal(int alarmId, DateTime newDateTime) async {
    try {
      final alarm = await _alarmApiService.getAlarmById(alarmId);
      if (alarm != null) {
        final updatedAlarm = AlarmModel(
          id: alarm.id,
          alarmDateTime: newDateTime,
          alarmEnabled: true,
          slug: alarm.slug,
        );
        final backendAlarm = await _alarmApiService.updateAlarm(alarm.slug, updatedAlarm);
        if (backendAlarm != null) {
          await _localAlarmService.setAlarm(
            backendAlarm.id!,
            backendAlarm.alarmDateTime,
            _titleController.text.trim(),
            'Tugas: ${_titleController.text.trim()} sudah waktunya!'
          );
        }
      }
    } catch (e) {
      debugPrint('Gagal update alarm: $e');
    }
  }

  Future<void> _deleteAlarmBackendAndLocal(int alarmId, String? slug) async {
    try {
      if (slug != null) {
        await _alarmApiService.deleteAlarm(slug);
      }
      await _localAlarmService.cancelAlarm(alarmId);
    } catch (e) {
      debugPrint('Gagal hapus alarm: $e');
    }
  }

  // Determine which alarm option was used based on the time difference
  String? _determineAlarmOption(DateTime deadline, DateTime alarmTime) {
    final difference = deadline.difference(alarmTime);

    if (difference.inSeconds == 0) return 'on_time';
    if (difference.inMinutes == 5) return '5_minutes';
    if (difference.inMinutes == 10) return '10_minutes';
    if (difference.inMinutes == 15) return '15_minutes';
    if (difference.inMinutes == 30) return '30_minutes';
    if (difference.inHours == 1) return '1_hour';
    if (difference.inDays == 1) return '1_day';
    if (difference.inDays == 2) return '2_days';
    if (difference.inDays == 7) return '1_week';

    return 'custom'; // If none of the predefined options match
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateWordCount);
    _descriptionController.removeListener(_updateDescriptionWordCount);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int _currentWordCount = 0;
  int _currentDescriptionWordCount = 0;

  void _updateWordCount() {
    final text = _titleController.text;
    setState(() {
      _currentWordCount = text.length;
    });
    if (text.length > 20) {
      final limitedText = text.substring(0, 20);
      _titleController.value = TextEditingValue(
        text: limitedText,
        selection: TextSelection.collapsed(offset: limitedText.length),
      );
    }
  }

  void _updateDescriptionWordCount() {
    final text = _descriptionController.text;
    setState(() {
      _currentDescriptionWordCount = text.length;
    });
    if (text.length > 200) {
      final limitedText = text.substring(0, 200);
      _descriptionController.value = TextEditingValue(
        text: limitedText,
        selection: TextSelection.collapsed(offset: limitedText.length),
      );
    }
  }

  bool _validateInputs() {
    setState(() {
      _deadlineError = _deadline == null ? 'Deadline wajib diisi' : null;
      _durationError = _estimatedDuration == null ? 'Durasi wajib diisi' : null;
      _categoryError = _selectedCategory == null ? 'Kategori wajib diisi' : null;
      _alarmDateTimeError =
          _isAlarmEnabled && _alarmDateTime == null
              ? 'Waktu alarm wajib diisi' : null;
    });
    return _deadlineError == null &&
        _durationError == null &&
        _categoryError == null &&
        _alarmDateTimeError == null &&
        _formKey.currentState!.validate();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul tugas wajib diisi';
    }
    if (value.trim().length > 20) {
      return 'Judul maksimal 20 karakter';
    }
    return null;
  }

  // Ganti _saveTask agar menggunakan API service
  void _saveTask() async {
    if (!_validateInputs()) return;
    try {
      int? alarmId;
      DateTime? alarmDateTimeToSet;
      // Selalu buat alarm (atau update jika sudah ada), enabled mengikuti toggle
      if (_alarmDateTime != null) {
        final alarmModel = AlarmModel(
          alarmDateTime: _alarmDateTime!,
          alarmEnabled: _isAlarmEnabled, // sesuai toggle
          slug: widget.existingTask?.alarmId != null ? (await _alarmApiService.getAlarmById(widget.existingTask!.alarmId!))?.slug ?? '' : '',
        );
        if (widget.existingTask?.alarmId != null) {
          // Update alarm jika sudah ada
          final updatedAlarm = await _alarmApiService.updateAlarm(alarmModel.slug, alarmModel);
          if (updatedAlarm != null && updatedAlarm.id != null) {
            alarmId = updatedAlarm.id;
            alarmDateTimeToSet = updatedAlarm.alarmDateTime;
          }
        } else {
          // Create alarm jika belum ada
          final createdAlarm = await _alarmApiService.createAlarm(alarmModel);
          if (createdAlarm != null && createdAlarm.id != null) {
            alarmId = createdAlarm.id;
            alarmDateTimeToSet = createdAlarm.alarmDateTime;
          } else {
            // fallback jika backend gagal, tetap set alarm lokal
            alarmId = DateTime.now().millisecondsSinceEpoch;
            alarmDateTimeToSet = _alarmDateTime;
          }
        }
        // Set/update alarm lokal
        if (alarmId != null && alarmDateTimeToSet != null) {
          if (_isAlarmEnabled) {
            await _localAlarmService.setAlarm(
              alarmId,
              alarmDateTimeToSet,
              _titleController.text.trim(),
              'Tugas: ${_titleController.text.trim()} sudah waktunya!'
            );
          } else {
            // Nonaktifkan alarm lokal (tanpa hapus)
            await _localAlarmService.cancelAlarm(alarmId);
          }
        }
      }
      // Estimasi durasi ke string (format H:i, misal: 01:05, 00:45, 12:00)
      final estDurationStr = _estimatedDuration != null
        ? '${_estimatedDuration!.inHours.toString().padLeft(2, '0')}:${(_estimatedDuration!.inMinutes % 60).toString().padLeft(2, '0')}'
        : '00:00';
      if (widget.existingTask == null) {
        // Tambah task baru
        final result = await _taskService.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          deadline: _deadline!,
          estimatedDuration: estDurationStr,
          category: _selectedCategory!.name.toLowerCase(),
          alarmId: alarmId,
        );
        debugPrint('TaskService.createTask result: isSuccess=[33m${result.isSuccess}[0m, message=[31m${result.message}[0m, task=${result.task}');
        if (result.isSuccess) {
          showCustomTopSnackbar(
            context: context,
            message: result.message,
            isError: false,
          );
          Future.delayed(const Duration(seconds: 0), () {
            AutoRouter.of(context).replaceAll([const TaskListRoute()]);
          });
        } else {
          showCustomTopSnackbar(
            context: context,
            message: result.message,
            isError: true,
          );
        }
      } else {
        // Edit task
        final result = await _taskService.updateTask(
          slug: widget.existingTask!.slug!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          deadline: _deadline!,
          estimatedDuration: estDurationStr,
          category: _selectedCategory!.name.toLowerCase(),
          alarmId: alarmId,
        );
        if (result.isSuccess) {
          showCustomTopSnackbar(
            context: context,
            message: result.message,
            isError: false,
          );
          Future.delayed(const Duration(seconds: 0), () {
            AutoRouter.of(context).replaceAll([const TaskListRoute()]);
          });
        } else {
          showCustomTopSnackbar(
            context: context,
            message: result.message,
            isError: true,
          );
        }
      }
    } catch (e) {
      showCustomTopSnackbar(
        context: context,
        message: 'Terjadi kesalahan: \n$e',
        isError: true,
      );
    }
  }

  // Calculate alarm time based on selected option and deadline
  DateTime _calculateAlarmTime(String optionId, DateTime deadline) {
    switch (optionId) {
      case 'on_time':
        return deadline;
      case '15_minutes':
        return deadline.subtract(const Duration(minutes: 15));
      case '30_minutes':
        return deadline.subtract(const Duration(minutes: 30));
      case '45_minutes':
        return deadline.subtract(const Duration(minutes: 45));
      case '1_hour':
        return deadline.subtract(const Duration(hours: 1));
      default:
        return deadline.subtract(const Duration(minutes: 15)); // Default option
    }
  }

  // Get display text for selected alarm option
  String _getAlarmOptionText(String? optionId) {
    if (optionId == null) return 'Pilih waktu notifikasi';

    switch (optionId) {
      case 'on_time':
        return 'Ketika batas waktu';
      case '15_minutes':
        return '15 menit sebelum batas waktu';
      case '30_minutes':
        return '30 menit sebelum batas waktu';
      case '45_minutes':
        return '45 menit sebelum batas waktu';
      case '1_hour':
        return '1 jam sebelum batas waktu';
      case 'custom':
        return 'Kustom';
      default:
        return 'Pilih waktu notifikasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.existingTask != null ? 'Edit Tugas' : 'Tambah Tugas',
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              TaskTitleField(
                controller: _titleController,
                currentWordCount: _currentWordCount,
                validator: _validateTitle,
              ),
              const SizedBox(height: 32),

              // Description Field
              _buildDescriptionField(),
              const SizedBox(height: 32),

              FieldTile(
                title: 'Batas Waktu',
                value:
                    _deadline == null
                        ? 'Pilih tenggat waktu'
                        : DateFormat(
                          'EEEE, d MMM yyyy, HH:mm',
                          'id_ID',
                        ).format(_deadline!),
                onTap: () async {
                  final result = await showDeadlinePickerBottomSheet(context);
                  if (result != null) {
                    setState(() {
                      _deadline = result;
                      _deadlineError = null;

                      // Validasi alarm terhadap deadline baru
                      final isNewDeadlineValid = result.isAfter(DateTime.now().add(const Duration(hours: 1)));

                      // Jika deadline kurang dari 1 jam dari sekarang, nonaktifkan alarm
                      if (!isNewDeadlineValid) {
                        _isAlarmEnabled = false;
                        _alarmDateTime = null;
                        _selectedAlarmOption = null;
                      }
                      // Jika deadline valid dan alarm option sudah dipilih, update alarm time
                      else if (_selectedAlarmOption != null &&
                          _selectedAlarmOption != 'custom') {
                        _alarmDateTime = _calculateAlarmTime(
                          _selectedAlarmOption!,
                          result,
                        );
                      }
                    });
                  }
                },
                error: _deadlineError,
              ),
              const SizedBox(height: 32),
              FieldTile(
                title: 'Estimasi waktu pengerjaan',
                value:
                    _estimatedDuration == null
                        ? 'Pilih durasi'
                        : '${_estimatedDuration!.inHours}j : ${_estimatedDuration!.inMinutes % 60}m',
                onTap: () async {
                  final result = await showDurationPickerBottomSheet(context);
                  if (result != null) {
                    setState(() {
                      _estimatedDuration = result;
                      _durationError = null;
                    });
                  }
                },
                error: _durationError,
              ),
              const SizedBox(height: 32),
              FieldTile(
                title: 'Kategori',
                value: _selectedCategory?.name ?? (categories.isNotEmpty ? categories.first.name : ''),
                onTap: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPickerScreen(
                        selectedCategory: _selectedCategory?.name ?? '',
                      ),
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      final foundCategory = categories.where((c) => c.name == selected);
                      _selectedCategory = foundCategory.isNotEmpty ? foundCategory.first : null;
                      _categoryError = null;
                    });
                  }
                },
                error: _categoryError,
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alarm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Switch(
                        value: _isAlarmEnabled,
                        trackColor: WidgetStateProperty.resolveWith(
                          (states) =>
                              states.contains(WidgetState.selected)
                                  ? const Color(0xFF5263F3)
                                  : Colors.grey.shade300,
                        ),
                        onChanged: (value) async {
                          setState(() {
                            _isAlarmEnabled = value;
                            _alarmToggleError = null;
                          });
                          if (value) {
                            // Toggle ON: Selalu create alarm baru dengan waktu dari user
                            if (_alarmDateTime != null) {
                              final alarmModel = AlarmModel(
                                alarmDateTime: _alarmDateTime!,
                                alarmEnabled: true,
                                slug: '',
                              );
                              final createdAlarm = await _alarmApiService.createAlarm(alarmModel);
                              if (createdAlarm != null && createdAlarm.id != null) {
                                await _localAlarmService.setAlarm(
                                  createdAlarm.id!,
                                  createdAlarm.alarmDateTime,
                                  _titleController.text.trim(),
                                  'Tugas: ${_titleController.text.trim()} sudah waktunya!'
                                );
                              }
                            }
                          } else {
                            // Toggle OFF: update alarm terakhir (jika ada) is_alarm_enabled=false, alarm_date_time=deadline
                            if (widget.existingTask?.alarmId != null && _deadline != null) {
                              final alarm = await _alarmApiService.getAlarmById(widget.existingTask!.alarmId!);
                              if (alarm != null) {
                                final updatedAlarm = AlarmModel(
                                  id: alarm.id,
                                  alarmDateTime: _deadline!,
                                  alarmEnabled: false,
                                  slug: alarm.slug,
                                );
                                await _alarmApiService.updateAlarm(alarm.slug, updatedAlarm);
                                // Update alarm lokal (bukan hapus): set alarm pada deadline, disabled
                                await _localAlarmService.setAlarm(
                                  alarm.id!,
                                  _deadline!,
                                  _titleController.text.trim(),
                                  'Tugas: ${_titleController.text.trim()} sudah waktunya!'
                                );
                                // Jika AlarmService mendukung flag enable/disable, tambahkan parameter enable: false
                              }
                            }
                          }
                        },
                        thumbColor: const WidgetStatePropertyAll(Colors.white),
                        overlayColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        trackOutlineColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  if (_isAlarmEnabled && _deadline != null) ...[
                    const SizedBox(height: 16),
                    FieldTile(
                      title: 'Atur Alarm',
                      value: _alarmLoading
                          ? 'Memuat alarm...'
                          : (_isAlarmEnabled && (_alarmDateTime != null || _customAlarmDateTime != null))
                              ? DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(_alarmDateTime ?? _customAlarmDateTime!)
                              : (_selectedAlarmOption == 'custom' && _customAlarmDateTime == null)
                                ? 'Kustom'
                                : _selectedAlarmOption != null
                                  ? _getAlarmOptionText(_selectedAlarmOption)
                                  : (widget.existingTask?.alarmId != null ? 'Memuat alarm...' : 'Belum diatur'),
                      onTap: _alarmLoading
                          ? null
                          : (_isAlarmEnabled && widget.existingTask?.alarmId != null)
                            ? () async {
                                // Ubah waktu alarm jika sudah ada alarmId
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlarmPickerScreen(
                                      selectedOption: _selectedAlarmOption,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    if (result is String && result.startsWith('custom:')) {
                                      final dateStr = result.substring(7);
                                      _selectedAlarmOption = 'custom';
                                      _customAlarmDateTime = DateTime.tryParse(dateStr);
                                      _alarmDateTime = _customAlarmDateTime;
                                      _alarmDateTimeError = null;
                                    } else if (result is String) {
                                      _selectedAlarmOption = result;
                                      _alarmDateTime = _calculateAlarmTime(
                                        result,
                                        _deadline!,
                                      );
                                      _alarmDateTimeError = null;
                                    }
                                  });
                                  // Update alarm backend & lokal
                                  if (_alarmDateTime != null && widget.existingTask?.alarmId != null) {
                                    await _updateAlarmBackendAndLocal(widget.existingTask!.alarmId!, _alarmDateTime!);
                                  }
                                }
                              }
                            : (_isAlarmEnabled ? () async {
                                if (_deadline == null) {
                                  showCustomTopSnackbar(
                                    context: context,
                                    message: 'Silakan pilih deadline terlebih dahulu',
                                    isError: true,
                                  );
                                  return;
                                }
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlarmPickerScreen(
                                      selectedOption: _selectedAlarmOption,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    if (result is String && result.startsWith('custom:')) {
                                      final dateStr = result.substring(7);
                                      _selectedAlarmOption = 'custom';
                                      _customAlarmDateTime = DateTime.tryParse(dateStr);
                                      _alarmDateTime = _customAlarmDateTime;
                                      _alarmDateTimeError = null;
                                    } else if (result is String) {
                                      _selectedAlarmOption = result;
                                      _alarmDateTime = _calculateAlarmTime(
                                        result,
                                        _deadline!,
                                      );
                                      _alarmDateTimeError = null;
                                    }
                                  });
                                }
                              } : null),
                      error: _alarmDateTimeError,
                    ),
                  ],
                  if (_isAlarmEnabled && _alarmDateTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Alarm akan berbunyi pada: ${DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(_alarmDateTime!)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  if (_alarmToggleError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _alarmToggleError ??
                            'Alarm hanya bisa diatur jika deadline > 1 jam dari sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _deadline ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _deadline ?? DateTime.now().add(const Duration(minutes: 15)),
      ),
    );
    if (time == null) return;

    setState(() {
      _customAlarmDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Jika alarm kustom lebih besar dari deadline, tidak valid
      if (_customAlarmDateTime!.isAfter(_deadline!)) {
        _alarmDateTimeError = 'Alarm tidak boleh lebih dari batas waktu';
        _alarmDateTime = null;
        _selectedAlarmOption = null;
      } else {
        _alarmDateTimeError = null;
        _alarmDateTime = _customAlarmDateTime;
      }
    });
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi (Opsional)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Tambahkan deskripsi tugas (maksimal 200 karakter)',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade700, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$_currentDescriptionWordCount/200 karakter',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color:
                    _currentDescriptionWordCount > 180
                        ? Colors.orange
                        : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
