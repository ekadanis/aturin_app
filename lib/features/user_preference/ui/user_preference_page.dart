import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/user_preference/widgets/user_ideal_time.dart';
import 'package:aturin_app/features/user_preference/widgets/user_preference_header.dart';
import 'package:aturin_app/features/user_preference/widgets/user_priority.dart';
import 'package:aturin_app/features/user_preference/widgets/user_sleep_period.dart';
import 'package:aturin_app/features/user_preference/widgets/user_target_frequency.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@RoutePage()
class UserPreferencePage extends StatefulWidget {
  const UserPreferencePage({super.key});

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  var currentStep = 1;
  var totalSteps = 4;
  TimeOfDay? sleepTime;
  TimeOfDay? awakeTime;

  Map<String, String?> errors = {};

  void nextStep() {
    if (currentStep < totalSteps) {
      setState(() {
        currentStep++;
      });
    }
  }

  void prevStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan pertanyaan berdasarkan step
    String question = switch (currentStep) {
      1 => 'Biasanya kamu mulai tidur dan bangun jam berapa, nih?',
      2 => 'Kamu paling semangat ngerjain tugas di jam berapa, sih?',
      3 =>
        'Aktivitas apa yang penting untuk kamu jaga dalam hidupmu tiap minggu?',
      4 =>
        'Kalau untuk Hiburan, kamu mau ngerjainnya berapa kali seminggu nih?',
      _ => throw Exception('Invalid step: $currentStep'),
    };

    String condition = switch (currentStep) {
      1 => '',
      2 => 'Pilih maksimal 2 jawaban',
      3 => 'Pilih maksimal 2 jawaban',
      4 => '',
      _ => throw Exception('Invalid step: $currentStep'),
    };

    // Tentukan widget berdasarkan step
    Widget content = switch (currentStep) {
      1 => UserSleepPeriod(
        sleepTime: sleepTime,
        awakeTime: awakeTime,
        onSleepTimeChanged: (time) {
          setState(() {
            sleepTime = time;
            errors.remove('sleepTime');
          });
        },
        onAwakeTimeChanged: (time) {
          setState(() {
            awakeTime = time;
            errors.remove('awakeTime');
          });
        },
      ),
      2 => UserIdealTime(),
      3 => UserPriority(),
      4 => UserTargetFrequency(),
      _ => throw Exception('Invalid step: $currentStep'),
    };

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            UserPreferenceHeader(
              currentStep: currentStep,
              totalSteps: totalSteps,
              question: question,
              condition: condition,
            ),

            SizedBox(height: 4),

            const Divider(
              color: Color(0xFFE4E4E7), // The color of the line
              thickness: 1.5, // The thickness of the line
              height: 20, // The total vertical space the divider occupies
              indent: 16, // Empty space on the left side
              endIndent: 16, // Empty space on the right side
            ),

            Expanded(child: content),

            Row(
              children: [
                if (currentStep > 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                      child: ElevatedButton(
                        onPressed: prevStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppTheme.accentColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: AppTheme.accentColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kembali',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (currentStep > 1) const SizedBox(width: 8),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                    child: ElevatedButton(
                      onPressed: nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjut',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.lightBackgroundColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: AppTheme.lightBackgroundColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
