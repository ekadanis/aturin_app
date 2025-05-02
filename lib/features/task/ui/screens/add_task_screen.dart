import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/task/ui/widgets/alarm_picker.dart';
import 'package:aturin_app/features/task/ui/widgets/task_title_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'categories.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import '../widgets/deadline_picker_bottom.dart';
import '../widgets/duration_picker_bottom.dart';
import '../widgets/category_list.dart';
import 'category_picker_screen.dart';
import '../../../../../../routers/app_router.dart';
import 'package:aturin_app/features/task/ui/widgets/alarm_picker_bottom.dart';
import 'package:aturin_app/features/task/ui/widgets/field_tile.dart';

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

  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    if (task != null) {
      _titleController.text = task.title;
      _deadline = task.deadline;
      _estimatedDuration = task.estimatedDuration;
      _selectedCategory = categories.firstWhere((c) => c.name == task.category);
      _isAlarmEnabled = task.isAlarmEnabled;
      _alarmDateTime = task.alarmDateTime;
    }
    _updateWordCount();
    _titleController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateWordCount);
    _titleController.dispose();
    super.dispose();
  }

  int _currentWordCount = 0;

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
        deadline: _deadline!,
        estimatedDuration: _estimatedDuration!,
        category: _selectedCategory!.name,
        isAlarmEnabled: _isAlarmEnabled,
        alarmDateTime: _isAlarmEnabled ? _alarmDateTime : null,
      ),
      isEdit: widget.existingTask != null,
      onSuccess: () {
        if (mounted) Navigator.pop(context, true);
      },
      onError: (msg) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDeadlineValid = _taskService.isDeadlineValid(_deadline);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.existingTask != null ? 'Edit Tugas' : 'Tambah Tugas'),
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
              FieldTile(
                title: 'Deadline',
                value:
                    _deadline == null
                        ? 'Pilih deadline'
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
                      final isNewDeadlineValid = _taskService.isDeadlineValid(result);
                      
                      // Jika deadline kurang dari 1 jam dari sekarang, nonaktifkan alarm
                      if (!isNewDeadlineValid) {
                        _isAlarmEnabled = false;
                        _alarmDateTime = null;
                      } 
                      // Jika deadline valid tapi alarm sudah diatur dan melebihi deadline baru - 1 jam
                      else if (_alarmDateTime != null) {
                        final maxAlarmTime = result.subtract(const Duration(hours: 1));
                        if (_alarmDateTime!.isAfter(maxAlarmTime)) {
                          _alarmDateTime = maxAlarmTime;
                        }
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
                value: _selectedCategory?.name ?? 'Pilih Kategori',
                onTap: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CategoryPickerScreen(
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
              AlarmPicker(
                isEnabled: _isAlarmEnabled,
                alarmDateTime: _alarmDateTime,
                onToggle:
                    isDeadlineValid
                        ? (value) {
                          setState(() {
                            _isAlarmEnabled = value;
                            if (!value) _alarmDateTime = null;
                            _alarmToggleError = null;
                          });
                        }
                        : (_) {
                          setState(() {
                            _alarmToggleError =
                                'Alarm hanya bisa diatur jika deadline > 1 jam dari sekarang';
                          });
                        },
                onPickTime: () async {
                  final maxDate = _deadline!.subtract(const Duration(hours: 1));
                  final result = await showAlarmPickerBottomSheet(
                    context,
                    initialDateTime: _alarmDateTime ?? maxDate,
                    maxDateTime: maxDate,
                  );
                  if (result != null) {
                    setState(() {
                      _alarmDateTime = result;
                      _alarmDateTimeError = null;
                    });
                  }
                },
                showInitialWarning: _deadline == null,
                errorText:
                    !isDeadlineValid && _deadline != null
                        ? 'Alarm hanya bisa diatur jika deadline > 1 jam dari sekarang'
                        : null,
                showError: !isDeadlineValid && _deadline != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
