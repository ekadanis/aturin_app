import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final bool editable;
  final VoidCallback? onEditPressed;

  const ProfileTextField({
    super.key,
    required this.label,
    this.value,
    this.controller,
    this.editable = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E4E7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF131927),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value ?? controller?.text ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF131927),
                ),
              ),
            ),
            if (editable) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEditPressed,
                child: SvgPicture.asset(
                  'assets/icons/edit_big.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
