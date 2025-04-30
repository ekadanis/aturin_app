import 'package:flutter/material.dart';

class TaskTitleField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: controller,
          maxLines: 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: 'Judul Tugas (maks. 20 karakter)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validator,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Text(
            '$currentWordCount/20 karakter',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
