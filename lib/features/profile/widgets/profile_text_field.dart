import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      setState(() {}); // Update UI on focus change
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _isError = true;
      });
      return; // Jangan panggil onSubmitted jika kosong
    }
    widget.onSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxChar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isError ? Colors.red : const Color(0xFFE4E4E7),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF131927),
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
                      : Text(
                          _controller.text.isNotEmpty
                              ? _controller.text
                              : 'Data belum diisi',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF131927),
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
                      if (widget.onEditPressed != null)
                        GestureDetector(
                          onTap: widget.onEditPressed,
                          child: SvgPicture.asset(
                            'assets/icons/edit_big.svg',
                            width: 20,
                            height: 20,
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
