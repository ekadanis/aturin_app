import 'package:flutter/material.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class TaskTitleField extends StatefulWidget {
  final TextEditingController controller;
  final int currentWordCount;
  final String? Function(String?)? validator;

  const TaskTitleField({
    super.key,
    required this.controller,
    required this.currentWordCount,
    required this.validator,
  });

  @override
  State<TaskTitleField> createState() => _TaskTitleFieldState();
}

class _TaskTitleFieldState extends State<TaskTitleField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: 'Masukan judul tugas',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: widget.validator,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Text(
            '${widget.currentWordCount}/20 karakter',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
