import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showCustomTopSnackbar({
  required BuildContext context,
  required String message,
  bool isError = false,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isError ? Colors.red[100] : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isError ? Colors.red : const Color(0xFF43A047),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/info_empty.svg',
                    width: 24,
                    height: 24,
                    color: isError ? Colors.red[900] : const Color(0xFF43A047),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color:
                            isError ? Colors.red[900] : const Color(0xFF263238),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => overlayEntry.remove(),
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: SvgPicture.asset(
                        'assets/icons/clear.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
