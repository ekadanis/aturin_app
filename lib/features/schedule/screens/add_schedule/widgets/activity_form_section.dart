import 'package:flutter/material.dart';
import 'package:aturin_app/features/schedule/widgets/form_field_widgets.dart';

class ActivityFormSection extends StatefulWidget {
  final String initialTitle;
  final String? titleError;
  final Function(String) onTitleChanged;

  const ActivityFormSection({
    super.key,
    required this.initialTitle,
    required this.titleError,
    required this.onTitleChanged,
  });

  @override
  State<ActivityFormSection> createState() => _ActivityFormSectionState();
}

class _ActivityFormSectionState extends State<ActivityFormSection> {
  late TextEditingController _titleController;
  static const int _maxCharCount = 20;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final text = _titleController.text;

    if (text.length > _maxCharCount) {
      final limitedText = text.substring(0, _maxCharCount);
      _titleController.value = TextEditingValue(
        text: limitedText,
        selection: TextSelection.collapsed(offset: limitedText.length),
      );
      return;
    }
    widget.onTitleChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return ActivityNameField(
      controller: _titleController,
      errorText: widget.titleError,
      maxCharCount: _maxCharCount,
    );
  }
}