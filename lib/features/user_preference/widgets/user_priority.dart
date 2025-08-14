import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/core/widgets/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserPriority extends StatefulWidget {
  const UserPriority({super.key});

  @override
  State<UserPriority> createState() => _UserPriorityState();
}

class _UserPriorityState extends State<UserPriority> {
  List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prioritas Aktivitas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategories.contains(category.name);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Jika sudah dipilih, hapus
                        selectedCategories.remove(category.name);
                      } else {
                        // Jika belum dipilih dan masih < 4, tambahkan
                        if (selectedCategories.length < 4) {
                          selectedCategories.add(category.name);
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
                          category.iconPath,
                          width: 24,
                          height: 24,
                          colorFilter:
                              isSelected
                                  ? ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  )
                                  : ColorFilter.mode(
                                    category.textColor,
                                    BlendMode.srcIn,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        // --- FIX: Correct icon display logic ---
                        // The check icon should be inside the Row to be visible.
                        // Using Opacity is a good way to show/hide it without changing layout.
                        Opacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          child: const Icon(
                            Icons.check_circle,
                            color:
                                Colors
                                    .white, // White check on a blue background
                          ),
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
