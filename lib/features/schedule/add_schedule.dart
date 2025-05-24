import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

@RoutePage()
class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        context.router.pushAndPopUntil(
          const ScheduleRoute(),
          predicate: (_) => false,
        );
        return;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        appBar: AppBar(
          title: Text(
            '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTextColor,
            ),
          ),
          elevation: 0,
          backgroundColor: AppTheme.lightBackgroundColor,
          foregroundColor: AppTheme.lightTextColor,
        ),
        body: const Center(
          child: Text(
            'Hello World',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
