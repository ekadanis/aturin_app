import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/task/screens/widgets/task_title_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import '../../model/task_model.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import '../../services/task_services.dart';
import '../widgets/deadline_picker_bottom.dart';
import '../widgets/duration_picker_bottom.dart';
import 'category_picker_screen.dart';
import 'alarm_picker_screen.dart';
import '../../../../../../routers/app_router.dart';
import 'package:aturin_app/core/widgets/field_tile.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';

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

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    if (task != null) {
      // Jika mengedit task
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _deadline = task.deadline;
      _estimatedDuration = task.estimatedDuration;
      _selectedCategory = categories.firstWhere((c) => c.name == task.category);
      _isAlarmEnabled = task.isAlarmEnabled;
      _alarmDateTime = task.alarmDateTime;
    } else {
      // Kalau tambah task baru, set default kategori ke "Akademik"
      _selectedCategory = categories.firstWhere((c) => c.name == 'Akademik');

      // Try to determine the alarm option based on the time difference
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
      _deadlineError = _taskService.validateDeadline(_deadline);
      _durationError = _taskService.validateDuration(_estimatedDuration);
      _categoryError = _taskService.validateCategory(_selectedCategory);
      _alarmDateTimeError =
          _isAlarmEnabled
              ? _taskService.validateAlarm(_deadline, _alarmDateTime)
              : null;
    });

    return _deadlineError == null &&
        _durationError == null &&
        _categoryError == null &&
        _alarmDateTimeError == null &&
        _formKey.currentState!.validate();
  }

  void _saveTask() {
    if (!_validateInputs()) return;

    _taskService.handleSaveForm(
      formKey: _formKey,
      task: Task(
        id: widget.existingTask?.id,
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        deadline: _deadline!,
        estimatedDuration: _estimatedDuration!,
        category: _selectedCategory!.name,
        isAlarmEnabled: _isAlarmEnabled,
        alarmDateTime: _isAlarmEnabled ? _alarmDateTime : null,
      ),
      isEdit: widget.existingTask != null,
      onSuccess: () {
        if (mounted) {
          showCustomTopSnackbar(
            context: context,
            message: 'Tugas berhasil disimpan',
            isError: false,
          );

          Future.delayed(const Duration(seconds: 0), () {
            AutoRouter.of(context).replaceAll([const TaskListRoute()]);
          });
        }
      },
      onError: (msg) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
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
  }  @override
  Widget build(BuildContext context) {
    final isDeadlineValid = _taskService.isDeadlineValid(_deadline);

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
                validator: _taskService.validateTitle,
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
                      final isNewDeadlineValid = _taskService.isDeadlineValid(
                        result,
                      );

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
                value: _selectedCategory?.name ?? 'Akademik ',
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
                      _selectedCategory = categories.firstWhere(
                        (c) => c.name == selected,
                      );
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
                        onChanged:
                            isDeadlineValid
                                ? (value) {
                                  setState(() {
                                    _isAlarmEnabled = value;
                                    if (!value) {
                                      _alarmDateTime = null;
                                      _selectedAlarmOption = null;
                                    }
                                    _alarmToggleError = null;
                                  });
                                }
                                : (_) {
                                  setState(() {
                                    _alarmToggleError =
                                        'Alarm hanya bisa diatur jika deadline > 1 jam dari sekarang';
                                  });
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
                      value: _selectedAlarmOption == 'custom' && _customAlarmDateTime != null
                          ? DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(_customAlarmDateTime!)
                          : _selectedAlarmOption != null
                              ? _getAlarmOptionText(_selectedAlarmOption)
                              : 'Kustom',
                      onTap: () async {
                        if (_deadline == null) {
                          showCustomTopSnackbar(
                            context: context,
                            message: 'Silakan pilih deadline terlebih dahulu',
                            isError: true,
                          );
                          return;
                        }

                        // Navigate to AlarmPickerScreen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlarmPickerScreen(
                              selectedOption: _selectedAlarmOption,
                            ),
                          ),
                        );

                        // Handle the result from AlarmPickerScreen
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
                      },
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
                  if (_alarmToggleError != null ||
                      (!isDeadlineValid && _deadline != null))
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
            ],
          ),
        ),
      ),
    );
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
        const SizedBox(height: 8),        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Tambahkan deskripsi tugas (maksimal 200 karakter)',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            contentPadding: const EdgeInsets.all(16),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
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
