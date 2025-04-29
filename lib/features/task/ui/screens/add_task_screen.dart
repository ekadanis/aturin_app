import 'package:aturin_app/core/theme/app_theme.dart';
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
import '../../../../routers/app_router.dart';
import 'package:aturin_app/features/task/ui/widgets/alarm_picker_bottom.dart';

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
    bool isValid = true;

    if (_deadline == null) {
      _deadlineError = 'Deadline wajib diisi';
      isValid = false;
    } else {
      _deadlineError = null;
    }

    if (_estimatedDuration == null) {
      _durationError = 'Estimasi waktu wajib diisi';
      isValid = false;
    } else {
      _durationError = null;
    }

    if (_selectedCategory == null) {
      _categoryError = 'Kategori wajib diisi';
      isValid = false;
    } else {
      _categoryError = null;
    }

    if (_isAlarmEnabled && _alarmDateTime == null) {
      _alarmDateTimeError = 'Waktu alarm wajib diisi';
      isValid = false;
    } else if (_isAlarmEnabled && _alarmDateTime != null && _deadline != null) {
      if (_alarmDateTime!.isAfter(_deadline!)) {
        _alarmDateTimeError = 'Alarm harus sebelum deadline';
        isValid = false;
      } else {
        _alarmDateTimeError = null;
      }
    }

    setState(() {});
    return isValid && _formKey.currentState!.validate();
  }

  void _saveTask() async {
    if (!_validateInputs()) return;

    final task = Task(
      id: widget.existingTask?.id,
      title: _titleController.text,
      deadline: _deadline!,
      estimatedDuration: _estimatedDuration!,
      category: _selectedCategory!.name,
      isAlarmEnabled: _isAlarmEnabled,
      alarmDateTime: _isAlarmEnabled ? _alarmDateTime : null,
    );

    try {
      if (widget.existingTask != null) {
        await _taskService.updateTask(task);
      } else {
        await _taskService.addTask(task);
      }
    } catch (e) {
      print('Error saat menyimpan tugas: $e');
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDeadlineValid =
        _deadline != null &&
        _deadline!.isAfter(now.add(const Duration(hours: 1)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _titleController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Judul Tugas (maks. 20 karakter)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Judul wajib diisi';
                      if (value.length > 20)
                        return 'Judul maksimal 20 karakter';
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      '$_currentWordCount/20 karakter',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              buildFieldTile(
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
                      if (_alarmDateTime != null &&
                          _alarmDateTime!.isAfter(result)) {
                        _alarmDateTime = null;
                      }
                    });
                  }
                },
                error: _deadlineError,
              ),
              const SizedBox(height: 32),
              buildFieldTile(
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
              buildFieldTile(
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
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!isDeadlineValid) {
                            setState(() {
                              _alarmToggleError =
                                  'Alarm hanya bisa diatur jika deadline > 1 jam dari sekarang';
                            });
                          }
                        },
                        child: AbsorbPointer(
                          absorbing: !isDeadlineValid,
                          child: Switch(
                            value: _isAlarmEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isAlarmEnabled = value;
                                if (!value) _alarmDateTime = null;
                                _alarmToggleError = null;
                              });
                            },
                            splashRadius: 0,
                            trackColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (!isDeadlineValid) return Colors.grey.shade200;
                              return states.contains(WidgetState.selected)
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300;
                            }),
                            thumbColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (!isDeadlineValid) return Colors.grey.shade400;
                              return Colors.white;
                            }),
                            overlayColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            trackOutlineColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _deadline == null
                          ? '*Pilih deadline terlebih dahulu untuk mengaktifkan alarm'
                          : !isDeadlineValid
                          ? 'Alarm hanya bisa diatur jika deadline > 1 jam dari sekarang'
                          : _alarmToggleError ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color:
                            (!_isAlarmEnabled ||
                                    !isDeadlineValid ||
                                    _alarmToggleError != null)
                                ? Colors.red
                                : Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isAlarmEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: buildFieldTile(
                    title: 'Waktu Alarm',
                    value:
                        _alarmDateTime == null
                            ? 'Pilih waktu alarm'
                            : DateFormat(
                              'EEEE, d MMM yyyy, HH:mm',
                              'id_ID',
                            ).format(_alarmDateTime!),
                    onTap: () async {
                      final maxDate = _deadline!.subtract(
                        const Duration(hours: 1),
                      );
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
                    error: _alarmDateTimeError,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFieldTile({
    required String title,
    required String value,
    VoidCallback? onTap,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (onTap != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              error,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
