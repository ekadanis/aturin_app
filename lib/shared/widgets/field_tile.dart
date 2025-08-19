import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;
  final String? error;
  final Widget? trailing;

  const FieldTile({
    super.key,
    required this.title,
    required this.value,
    this.onTap,
    this.error,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '*',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              trailing != null
                  ? trailing!
                  : Row(
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
              error!,
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
