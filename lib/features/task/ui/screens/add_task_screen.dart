import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'categories.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import '../widgets/deadline_picker_bottom.dart';
import '../widgets/duration_picker_bottom.dart';
import '../widgets/category_list.dart';
import 'category_picker_screen.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
  
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  DateTime? _deadline;
  Duration? _estimatedDuration;
  CategoryOption _selectedCategory = categories.first;
  bool _isAlarmEnabled = false;
  DateTime? _alarmDateTime;

  final TaskService _taskService = TaskService();

  void _saveTask() async {
    if (!_formKey.currentState!.validate() || _deadline == null || _estimatedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field terlebih dahulu')),
      );
      return;
    }

    final task = Task(
      title: _titleController.text,
      deadline: _deadline!,
      estimatedDuration: _estimatedDuration!,
      category: _selectedCategory.name,
      isAlarmEnabled: _isAlarmEnabled,
      alarmDateTime: _isAlarmEnabled ? _alarmDateTime : null,
    );

    await _taskService.addTask(task);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Tugas'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('Deadline'),
                subtitle: Text(_deadline == null
                    ? 'Pilih deadline'
                    : DateFormat('EEEE, d MMM yyyy - HH:mm', 'id_ID').format(_deadline!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final result = await showDeadlinePickerBottomSheet(context);
                  if (result != null) setState(() => _deadline = result);
                },
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('Estimasi Waktu Pengerjaan'),
                subtitle: Text(_estimatedDuration == null
                    ? 'Pilih durasi'
                    : '${_estimatedDuration!.inHours} Jam ${_estimatedDuration!.inMinutes % 60} Menit'),
                trailing: const Icon(Icons.timer_outlined),
                onTap: () async {
                  final result = await showDurationPickerBottomSheet(context);
                  if (result != null) setState(() => _estimatedDuration = result);
                },
              ),
              const SizedBox(height: 16),

              CategoryListTile(
                category: _selectedCategory,
                onTap: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPickerScreen(selectedCategory: _selectedCategory.name),
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedCategory = categories.firstWhere((c) => c.name == selected);
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Aktifkan Alarm'),
                value: _isAlarmEnabled,
                onChanged: (value) => setState(() => _isAlarmEnabled = value),
              ),

              if (_isAlarmEnabled)
                ListTile(
                  title: const Text('Waktu Alarm'),
                  subtitle: Text(_alarmDateTime == null
                      ? 'Pilih waktu alarm'
                      : DateFormat('EEEE, d MMM yyyy - HH:mm', 'id_ID').format(_alarmDateTime!)),
                  trailing: const Icon(Icons.alarm),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _alarmDateTime = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
