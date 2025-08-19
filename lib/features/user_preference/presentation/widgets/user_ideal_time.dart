import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:aturin_app/features/user_preference/data/models/ideal_times.dart';

class UserIdealTime extends StatefulWidget {
  const UserIdealTime({super.key});

  @override
  State<UserIdealTime> createState() => _UserIdealTimeState();
}

class _UserIdealTimeState extends State<UserIdealTime> {
  List<String> selectedTime = [];

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
            'Jam Fokus Ideal',
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
              itemCount: idealTimes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final idealTime = idealTimes[index];
                final isSelected = selectedTime.contains(idealTime.name);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Jika sudah dipilih, hapus
                        selectedTime.remove(idealTime.name);
                      } else {
                        // Jika belum dipilih dan masih < 4, tambahkan
                        if (selectedTime.length < 2) {
                          selectedTime.add(idealTime.name);
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
                        SvgPicture.asset(
                          idealTime.iconPath,
                          width: 24,
                          height: 24,
                          colorFilter:
                              isSelected
                                  ? ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  )
                                  : ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                        ),
                        Expanded(
                          child: Text(
                            idealTime.name,
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
