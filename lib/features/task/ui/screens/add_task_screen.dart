import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart'; // Menambahkan import auto_route
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

  // Variabel untuk pesan error
  String? _deadlineError;
  String? _durationError;
  String? _categoryError;
  String? _alarmDateTimeError;

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

    // Initialize word count right away
    _updateWordCount();

    // Add listener for text changes
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

    if (text.isEmpty) {
      setState(() {
        _currentWordCount = 0;
      });
      return;
    }

    final cleanText = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final wordList = cleanText.isEmpty ? [] : cleanText.split(' ');

    if (mounted) {
      setState(() {
        _currentWordCount = wordList.length;
      });
    }

    // Prevent typing if word count exceeds 20
    if (wordList.length > 20) {
      final limitedText = wordList.sublist(0, 20).join(' ');

      // Keep cursor position or place at end
      final currentPosition = _titleController.selection.baseOffset;
      final newPosition =
          currentPosition > limitedText.length
              ? limitedText.length
              : currentPosition;

      _titleController.value = TextEditingValue(
        text: limitedText,
        selection: TextSelection.collapsed(offset: newPosition),
      );
    }
  }

  bool _validateInputs() {
    bool isValid = true;

    // Validasi deadline
    if (_deadline == null) {
      setState(() {
        _deadlineError = 'Deadline wajib diisi';
      });
      isValid = false;
    } else {
      setState(() {
        _deadlineError = null;
      });
    }

    // Validasi durasi
    if (_estimatedDuration == null) {
      setState(() {
        _durationError = 'Estimasi waktu wajib diisi';
      });
      isValid = false;
    } else {
      setState(() {
        _durationError = null;
      });
    }

    // Validasi kategori
    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Kategori wajib diisi';
      });
      isValid = false;
    } else {
      setState(() {
        _categoryError = null;
      });
    }

    // Validasi alarm jika diaktifkan
    if (_isAlarmEnabled && _alarmDateTime == null) {
      setState(() {
        _alarmDateTimeError = 'Waktu alarm wajib diisi';
      });
      isValid = false;
    } else if (_isAlarmEnabled && _deadline != null && _alarmDateTime != null) {
      // Pastikan alarm sebelum deadline
      if (_alarmDateTime!.isAfter(_deadline!)) {
        setState(() {
          _alarmDateTimeError = 'Waktu alarm harus sebelum deadline';
        });
        isValid = false;
      } else {
        setState(() {
          _alarmDateTimeError = null;
        });
      }
    } else {
      setState(() {
        _alarmDateTimeError = null;
      });
    }

    return isValid && _formKey.currentState!.validate();
  }

  void _saveTask() async {
    if (!_validateInputs()) {
      return;
    }

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
        // EDIT mode
        await _taskService.updateTask(task);
      } else {
        // ADD mode
        await _taskService.addTask(task);
      }
    } catch (e) {
      print('Error saat menyimpan tugas: $e');
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  bool _isTitleExceeds20Words(String text) {
    final cleanText = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final words = cleanText.split(' ');
    return words.length > 20;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveTask),
        ],
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // TextFormField dengan word counter
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _titleController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Judul Tugas (maks. 20 kata)',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul tugas wajib diisi';
                      }
                      if (_isTitleExceeds20Words(value)) {
                        return 'Judul tidak boleh lebih dari 20 kata';
                      }
                      return null;
                    },
                  ),

                  // Word counter yang diposisikan di kanan
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Text(
                      '$_currentWordCount/20',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

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

                      // Reset alarm jika deadline berubah dan alarm setelah deadline
                      if (_alarmDateTime != null &&
                          _alarmDateTime!.isAfter(result)) {
                        _alarmDateTime = null;
                      }
                    });
                  }
                },
                error: _deadlineError,
              ),

              const SizedBox(height: 45),

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

              const SizedBox(height: 45),

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

              const SizedBox(height: 45),

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
                  Switch(
                    value: _isAlarmEnabled,
                    onChanged:
                        _deadline == null
                            ? null // Disable switch jika deadline belum dipilih
                            : (value) {
                              setState(() {
                                _isAlarmEnabled = value;
                                if (!value) {
                                  _alarmDateTime = null;
                                  _alarmDateTimeError = null;
                                }
                              });
                            },
                    splashRadius: 0,
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (_deadline == null) {
                        return Colors.grey.shade200; // Warna saat disabled
                      }
                      return states.contains(WidgetState.selected)
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300;
                    }),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (_deadline == null) {
                        return Colors
                            .grey
                            .shade400; // Warna thumb saat disabled
                      }
                      return Colors.white;
                    }),
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                ],
              ),

              // Pesan info jika deadline belum dipilih
              if (_deadline == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '*Pilih deadline terlebih dahulu untuk mengaktifkan alarm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              if (_isAlarmEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildFieldTile(
                        title: 'Waktu Alarm',
                        value:
                            _alarmDateTime == null
                                ? 'Pilih waktu alarm'
                                : DateFormat(
                                  'EEEE, d MMM yyyy, HH:mm',
                                  'id_ID',
                                ).format(_alarmDateTime!),
                        onTap: () async {
                          if (_deadline != null) {
                            // Mengubah dari 1 hari menjadi 1 jam sebelum deadline
                            final maxDate = _deadline!.subtract(
                              const Duration(hours: 1),
                            );

                            final result = await showAlarmPickerBottomSheet(
                              context,
                              initialDateTime: _alarmDateTime ?? maxDate,
                              maxDateTime:
                                  maxDate, // Batasi maksimal waktu alarm
                            );

                            if (result != null) {
                              setState(() {
                                _alarmDateTime = result;
                                _alarmDateTimeError = null;
                              });
                            }
                          }
                        },
                        error: _alarmDateTimeError,
                      ),
                      if (_deadline != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            '*Alarm hanya dapat diatur minimal 1 jam sebelum deadline',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
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
