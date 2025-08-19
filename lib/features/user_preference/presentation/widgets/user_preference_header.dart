import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserPreferenceHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String question;
  final String condition;
  const UserPreferenceHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.question,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teks langkah
          Text(
            'Pertanyaan $currentStep dari $totalSteps',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),

          // --- FIX: Restructured this Row ---
          Row(
            children: [
              // Return button is now a direct child of the Row
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/back.svg',
                  width: 16,
                  height: 16,
                ),
                onPressed: () {
                  // Use AutoRouter or Navigator to pop
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 8), // Added some spacing
              // Progress bar is wrapped in Expanded to take up remaining space
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Added some vertical spacing
          // --- FIX: Simplified the mascot and chat bubble layout ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/mascot.png',
                height: 100, // Adjusted height for better alignment
                width: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              // Use Expanded to allow the chat bubble to fill the space and wrap text if needed
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFDFEAFF), // Primary-100
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        condition,
                        style: TextStyle(
                          color: const Color(0xFF5263F3),
                          fontSize: 10,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
