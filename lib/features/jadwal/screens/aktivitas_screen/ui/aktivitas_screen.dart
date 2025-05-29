import 'package:aturin_app/core/widgets/calendar_section_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/category_tabs_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/infinite_schedule_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/jadwal/services/aktivitas_service.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';

@RoutePage()
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  String selectedCategory = 'Semua';
  late DateTime selectedDate;
  late DateTime focusedDate;
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    focusedDate = DateTime(now.year, now.month, now.day);
    // Tambahkan agar data aktivitas di-fetch ulang setelah hot reload
    Future.microtask(() =>
      Provider.of<AktivitasService>(context, listen: false).fetchAktivitas()
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (_) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Text(
                      'Aktivitas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryTabsWidget(
                selectedCategory: selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 20),
              // Calendar Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: CalendarSectionWidget(
                  selectedDate: selectedDate,
                  focusedDate: focusedDate,
                  calendarFormat: calendarFormat,
                  schedules: [],
                  onDateSelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      focusedDate = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      focusedDate = focusedDay;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Schedule List
              Expanded(
                child: Consumer<AktivitasService>(
                  builder: (context, aktivitasService, _) {
                    final aktivitasList = aktivitasService.aktivitasList.where((a) {
                      final isSameDate = a.activityDate.year == selectedDate.year &&
                          a.activityDate.month == selectedDate.month &&
                          a.activityDate.day == selectedDate.day;
                      final isCategory = selectedCategory == 'Semua' ||
                          a.activityCategory.displayName == selectedCategory;
                      return isSameDate && isCategory;
                    }).toList();                    return InfiniteScheduleListWidget(
                      tasks: [],
                      schedules: aktivitasList,
                      selectedCategory: selectedCategory,
                      selectedDate: selectedDate,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      onEditSchedule: (aktivitas) => _editActivity(aktivitas),
                      onDeleteSchedule: (aktivitas) => _deleteActivity(aktivitas),
                    );
                  },
                ),
              ),
            ],
          ),
        ),        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      ),
    );
  }

  void _editActivity(AktivitasModel aktivitas) {
    context.router.push(AddAktivitasRoute(existingAktivitas: aktivitas));
  }
  void _deleteActivity(AktivitasModel aktivitas) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        iconPath: 'assets/activitycategory/trash-round-tipis.svg',
        title: 'Hapus Aktivitas',
        description: 'Yakin nih kamu mau hapus aktivitas ini?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
        isTask: false, // Pastikan ini diset false untuk aktivitas
        onConfirm: () async {
          try {
            final aktivitasService = Provider.of<AktivitasService>(context, listen: false);
            await aktivitasService.deleteAktivitas(aktivitas.id!);
            
            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Aktivitas berhasil dihapus',
                isError: false,
              );
            }
          } catch (e) {
            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Gagal menghapus aktivitas: ${e.toString()}',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }
}
