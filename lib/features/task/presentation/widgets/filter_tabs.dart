import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterTabs extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final int overdueTasksCount;
  final Function(String) onFilterSelected;

  const FilterTabs({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.overdueTasksCount,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Increase top padding to accommodate the badge
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = filter == selectedFilter;
              final isOverdue = filter == 'Terlambat';

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                // Add extra top padding to each filter item to make room for badge
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () => onFilterSelected(filter),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // The filter tab
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),

                        // Badge for overdue tasks count
                        if (isOverdue && overdueTasksCount > 0)
                          Positioned(
                            top: -10,
                            right: -10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  overdueTasksCount > 99
                                      ? '99+'
                                      : overdueTasksCount.toString(),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
