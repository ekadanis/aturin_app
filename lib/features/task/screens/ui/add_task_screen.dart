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
import '../../../../core/widgets/alarm_configuration_section.dart';
import '../../../../../../routers/app_router.dart';
import 'package:aturin_app/core/widgets/field_tile.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:aturin_app/features/alarm/services/alarm_service.dart';
import 'dart:async';

@RoutePage()
class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Form and Controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Task Data
  DateTime? _deadline;
  Duration? _estimatedDuration;
  CategoryOption? _selectedCategory;

  // Alarm Data
  bool _isAlarmEnabled = false;
  DateTime? _alarmDateTime;

  // UI State
  bool _isLoading = false;
  int _currentWordCount = 0;
  int _currentDescriptionWordCount = 0;
  Timer? _debounceTimer;

  // Error State
  final Map<String, String?> _errors = {
    'deadline': null,
    'duration': null,
    'category': null,
    'alarmDateTime': null,
  };

  // Services
  final TaskApiService _taskService = TaskApiService();
  final AlarmApiService _alarmApiService = AlarmApiService();
  final AlarmService _localAlarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    _initializeTask();
    _setupListeners();
  }

  void _initializeTask() {
    final task = widget.existingTask;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _deadline = task.deadline;
      _estimatedDuration = task.estimatedDuration;

      // Set category
      _selectedCategory = _findCategoryByName(task.category);

      // Set alarm if exists
      if (task.alarmId != null) {
        _isAlarmEnabled = true;
        _fetchAndSetAlarm(task.alarmId!);
      }
    } else {
      // Default category for new task
      _selectedCategory =
          _findCategoryByName('akademik') ??
          (categories.isNotEmpty ? categories.first : null);
    }

    _updateWordCounts();
  }

  CategoryOption? _findCategoryByName(String categoryName) {
    try {
      return categories.firstWhere(
        (c) => c.name.toLowerCase().trim() == categoryName.toLowerCase().trim(),
      );
    } catch (e) {
      return null;
    }
  }

  void _setupListeners() {
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onTitleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _updateWordCounts();
        _enforceCharacterLimit(_titleController, 20);
      }
    });
  }

  void _onDescriptionChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _updateWordCounts();
        _enforceCharacterLimit(_descriptionController, 200);
      }
    });
  }

  void _updateWordCounts() {
    setState(() {
      _currentWordCount = _titleController.text.length;
      _currentDescriptionWordCount = _descriptionController.text.length;
    });
  }

  void _enforceCharacterLimit(TextEditingController controller, int maxLength) {
    final text = controller.text;
    if (text.length > maxLength) {
      final limitedText = text.substring(0, maxLength);
      controller.value = TextEditingValue(
        text: limitedText,
        selection: TextSelection.collapsed(offset: limitedText.length),
      );
    }
  }

  Future<void> _fetchAndSetAlarm(int alarmId) async {
    try {
      final allAlarms = await _alarmApiService.getAllAlarms();
      final alarm = allAlarms.where((alarm) => alarm.id == alarmId).firstOrNull;

      if (alarm != null && mounted) {
        setState(() {
          _alarmDateTime = alarm.alarmDateTime;
        });

        // Sync to local alarm
        await _localAlarmService.setAlarm(
          alarm.id!,
          alarm.alarmDateTime,
          _titleController.text.trim(),
          'Tugas: ${_titleController.text.trim()} sudah waktunya!',
        );
      }
    } catch (e) {
      debugPrint('Gagal mengambil alarm: $e');
      if (mounted) {
        _showErrorSnackbar('Gagal memuat data alarm');
      }
    }
  }

  // Validation Methods
  bool _validateInputs() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _errors['deadline'] = _deadline == null ? 'Deadline wajib diisi' : null;
      _errors['duration'] =
          _estimatedDuration == null ? 'Durasi wajib diisi' : null;
      _errors['category'] =
          _selectedCategory == null ? 'Kategori wajib diisi' : null;
      _errors['alarmDateTime'] =
          _isAlarmEnabled && _alarmDateTime == null
              ? 'Waktu alarm wajib diisi'
              : null;
    });

    return isFormValid && _errors.values.every((error) => error == null);
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

  // Alarm Management Methods
  Future<int?> _createOrUpdateAlarm() async {
    if (_alarmDateTime == null) return null;

    try {
      final existingTask = widget.existingTask;
      String slug = '';

      if (existingTask?.alarmId != null) {
        // Update existing alarm
        final allAlarms = await _alarmApiService.getAllAlarms();
        final existingAlarm =
            allAlarms
                .where((alarm) => alarm.id == existingTask!.alarmId!)
                .firstOrNull;
        slug = existingAlarm?.slug ?? '';
      }

      final alarmModel = AlarmModel(
        alarmDateTime: _alarmDateTime!,
        alarmEnabled: _isAlarmEnabled,
        slug: slug,
      );

      AlarmModel? resultAlarm;

      if (existingTask?.alarmId != null) {
        // Update alarm
        resultAlarm = await _alarmApiService.updateAlarm(slug, alarmModel);
      } else {
        // Create new alarm
        resultAlarm = await _alarmApiService.createAlarm(alarmModel);
      }

      if (resultAlarm?.id != null) {
        // Set local alarm
        if (_isAlarmEnabled) {
          await _localAlarmService.setAlarm(
            resultAlarm!.id!,
            resultAlarm.alarmDateTime,
            _titleController.text.trim(),
            'Tugas: ${_titleController.text.trim()} sudah waktunya!',
          );
        } else {
          await _localAlarmService.cancelAlarm(resultAlarm!.id!);
        }

        return resultAlarm.id;
      }
    } catch (e) {
      debugPrint('Gagal mengelola alarm: $e');
      // Return a fallback ID for local alarm
      if (_isAlarmEnabled) {
        final fallbackId = DateTime.now().millisecondsSinceEpoch;
        await _localAlarmService.setAlarm(
          fallbackId,
          _alarmDateTime!,
          _titleController.text.trim(),
          'Tugas: ${_titleController.text.trim()} sudah waktunya!',
        );
        return fallbackId;
      }
    }

    return null;
  }

  // Task Save Method
  Future<void> _saveTask() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      // Handle alarm
      final alarmId = await _createOrUpdateAlarm();

      // Format duration
      final durationStr =
          _estimatedDuration != null
              ? '${_estimatedDuration!.inHours.toString().padLeft(2, '0')}:${(_estimatedDuration!.inMinutes % 60).toString().padLeft(2, '0')}'
              : '00:00';      TaskResult result;

      if (widget.existingTask == null) {
        // Create new task
        result = await _taskService.createTask(
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          deadline: _deadline!,
          estimatedDuration: durationStr,
          category: _selectedCategory!.name.toLowerCase(),
          alarmId: alarmId,
        );
      } else {
        // Update existing task
        result = await _taskService.updateTask(
          slug: widget.existingTask!.slug!,
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          deadline: _deadline!,
          estimatedDuration: durationStr,
          category: _selectedCategory!.name.toLowerCase(),
          alarmId: alarmId,
        );
      }

      if (result.isSuccess) {
        _showSuccessSnackbar(result.message);
        _navigateToTaskList();
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      debugPrint('Error saving task: $e');
      _showErrorSnackbar('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigation and UI Methods
  void _navigateToTaskList() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AutoRouter.of(context).replaceAll([const TaskListRoute()]);
      }
    });
  }

  void _showSuccessSnackbar(String message) {
    showCustomTopSnackbar(context: context, message: message, isError: false);
  }

  void _showErrorSnackbar(String message) {
    showCustomTopSnackbar(context: context, message: message, isError: true);
  }

  void _clearErrors() {
    setState(() {
      _errors.updateAll((key, value) => null);
    });
  }

  // Event Handlers
  Future<void> _onDeadlineChanged() async {
    final result = await showDeadlinePickerBottomSheet(context);
    if (result != null) {
      setState(() {
        _deadline = result;
        _errors['deadline'] = null;

        // Validate alarm against new deadline
        final isDeadlineValid = result.isAfter(
          DateTime.now().add(const Duration(hours: 1)),
        );

        if (!isDeadlineValid) {
          _isAlarmEnabled = false;
          _alarmDateTime = null;
        }
      });
    }
  }

  Future<void> _onDurationChanged() async {
    final result = await showDurationPickerBottomSheet(context);
    if (result != null) {
      setState(() {
        _estimatedDuration = result;
        _errors['duration'] = null;
      });
    }
  }

  Future<void> _onCategoryChanged() async {
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
        _selectedCategory = _findCategoryByName(selected);
        _errors['category'] = null;
      });
    }
  }

  void _onAlarmToggleChanged(bool value) {
    setState(() {
      _isAlarmEnabled = value;
      if (!value) {
        _alarmDateTime = null;
        _errors['alarmDateTime'] = null;
      }
    });
  }

  void _onAlarmTimeChanged(DateTime dateTime) {
    setState(() {
      _alarmDateTime = dateTime;
      _errors['alarmDateTime'] = null;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.existingTask != null ? 'Edit Tugas' : 'Tambah Tugas'),
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.check),
          onPressed: _isLoading ? null : _saveTask,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // Title Field
            TaskTitleField(
              controller: _titleController,
              currentWordCount: _currentWordCount,
              validator: _validateTitle,
            ),
            const SizedBox(height: 32),

            // Description Field
            _buildDescriptionField(),
            const SizedBox(height: 32),

            // Deadline Field
            FieldTile(
              title: 'Batas Waktu',
              value:
                  _deadline == null
                      ? 'Pilih tenggat waktu'
                      : DateFormat(
                        'EEEE, d MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(_deadline!),
              onTap: _onDeadlineChanged,
              error: _errors['deadline'],
            ),
            const SizedBox(height: 32),

            // Duration Field
            FieldTile(
              title: 'Estimasi waktu pengerjaan',
              value:
                  _estimatedDuration == null
                      ? 'Pilih durasi'
                      : '${_estimatedDuration!.inHours}j : ${_estimatedDuration!.inMinutes % 60}m',
              onTap: _onDurationChanged,
              error: _errors['duration'],
            ),
            const SizedBox(height: 32),

            // Category Field
            FieldTile(
              title: 'Kategori',
              value:
                  _selectedCategory?.name ??
                  (categories.isNotEmpty ? categories.first.name : ''),
              onTap: _onCategoryChanged,
              error: _errors['category'],
            ),
            const SizedBox(height: 32),

            // Alarm Configuration
            AlarmConfigurationSection(
              isEnabled: _isAlarmEnabled,
              alarmDateTime: _alarmDateTime,
              selectedDate: _deadline ?? DateTime.now(),
              startTime:
                  _deadline != null ? TimeOfDay.fromDateTime(_deadline!) : null,
              onToggle: _onAlarmToggleChanged,
              onAlarmTimeChanged: _onAlarmTimeChanged,
            ),

            const SizedBox(height: 32),
          ],
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
