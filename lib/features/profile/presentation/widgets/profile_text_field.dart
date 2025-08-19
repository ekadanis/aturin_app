import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ProfileTextField extends StatefulWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final bool editable;
  final VoidCallback? onEditPressed;
  final VoidCallback? onSubmitted;
  final int? maxChar;

  const ProfileTextField({
    super.key,
    required this.label,
    this.value,
    this.controller,
    this.editable = false,
    this.onEditPressed,
    this.onSubmitted,
    this.maxChar,
  });

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isError = false;
  bool _nonEditableTapped = false;
  Timer? _nonEditableTapTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();

    if (_controller.text.isEmpty && (widget.value?.isNotEmpty ?? false)) {
      _controller.text = widget.value!;
    }

    _controller.addListener(() {
      if (_isError && _controller.text.isNotEmpty) {
        setState(() {
          _isError = false;
        });
      } else {
        setState(() {}); // Update char count
      }
    });

    _focusNode.addListener(() {
      setState(() {});
    });

    if (widget.editable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _nonEditableTapTimer?.cancel();
    super.dispose();
  }

  void _handleSubmitted() {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _isError = true;
      });
      return;
    }
    widget.onSubmitted?.call();
  }

  void _handleNonEditableTap() {
    setState(() {
      _nonEditableTapped = true;
    });

    _nonEditableTapTimer?.cancel();
    _nonEditableTapTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _nonEditableTapped = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxChar;
    final textColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isError || _nonEditableTapped
                  ? Colors.red
                  : const Color(0xFFE4E4E7),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: widget.editable
                        ? const Color(0xFF131927)
                        : AppTheme.detailTextColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: widget.editable
                      ? TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onSubmitted: (_) => _handleSubmitted(),
                          maxLength: maxLength,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            counterText: '',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF131927),
                          ),
                        )
                      : GestureDetector(
                          onTap: _handleNonEditableTap,
                          child: Text(
                            _controller.text.isNotEmpty
                                ? _controller.text
                                : 'Data belum diisi',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.detailTextColor,
                            ),
                          ),
                        ),
                ),
                if (widget.editable &&
                    (_focusNode.hasFocus && maxLength != null ||
                        widget.onEditPressed != null))
                  Row(
                    children: [
                      if (_focusNode.hasFocus && maxLength != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8, top: 2),
                          child: Text(
                            '$currentLength / $maxLength',
                            style: TextStyle(
                              fontSize: 12,
                              color: currentLength > maxLength
                                  ? Colors.red
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (_isError)
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 6),
            child: Text(
              'Nama tidak boleh kosong',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        if (_nonEditableTapped)
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 6),
            child: Text(
              'Data ini tidak bisa diubah',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
