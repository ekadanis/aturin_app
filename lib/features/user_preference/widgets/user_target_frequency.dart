import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TargetFrequencyOption {
  final String name;

  const TargetFrequencyOption({required this.name});
}

final List<TargetFrequencyOption> targetFrequencies = [
  TargetFrequencyOption(name: '1x seminggu'),
  TargetFrequencyOption(name: '2x seminggu'),
  TargetFrequencyOption(name: '3x seminggu'),
  TargetFrequencyOption(name: '4x seminggu'),
];

class UserTargetFrequency extends StatefulWidget {
  const UserTargetFrequency({super.key});

  @override
  State<UserTargetFrequency> createState() => _UserTargetFrequencyState();
}

class _UserTargetFrequencyState extends State<UserTargetFrequency> {
  List<String> selectedTarget = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Target Frekuensi Aktivitas',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              height: 1.50,
              letterSpacing: 0.08,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: NeverScrollableScrollPhysics(),
              itemCount: targetFrequencies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final targetFrequency = targetFrequencies[index];
                final isSelected = selectedTarget.contains(
                  targetFrequency.name,
                );

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Jika sudah dipilih, hapus
                        selectedTarget.remove(targetFrequency.name);
                      } else {
                        // Jika belum dipilih dan masih < 4, tambahkan
                        if (selectedTarget.length < 4) {
                          selectedTarget.add(targetFrequency.name);
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            targetFrequency.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
