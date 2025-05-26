import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF5263F3); // Primary blue color
  static const Color buttonBackgroundColor = Color(0xFFC6D6FF);

  // Light theme colors
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Color(0xFF131927);
  static const Color lightSecondaryTextColor = Color(0xFF71717A);
  static const Color lightDividerColor = Color(0xFFE4E4E7);
  static const Color lightErrorColor = Color(0xFFEF4444);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Colors.white;
  static const Color darkSecondaryTextColor = Color(0xFFAAAAAA);
  static const Color darkDividerColor = Color(0xFF2A2A2A);

  // Accent colors
  static const Color accentColor = Color(0xFF6E7BFF);
  static const Color successColor = Color(0xFF3DA755);
  static const Color warningColor = Color(0xFFE6A73C);
  static const Color dangerColor = Color(0xFFD34141);

  // Task status colors
  static const Color lateColor = Color(0xFFFFDDDD);
  static const Color lateTextColor = Color(0xFFFF6B6B);
  static const Color todayColor = Color(0xFFE3F2F9);
  static const Color todayTextColor = Color(0xFF2196F3);
  static const Color tomorrowColor = Color(0xFFFFF8E1);
  static const Color tomorrowTextColor = Color(0xFFFFC107);
  static const Color upcomingColor = Color(0xFFF5F5F5);
  static const Color upcomingTextColor = Color(0xFF9E9E9E);
  static const Color completedColor = Color(0xFFE3F2E9);
  static const Color completedTextColor = Color(0xFF4CAF50);
  // Action colors
  static const Color detailBackgroundColor = Color(0xFFF5F5F5);
  static const Color detailTextColor = Color(0xFF71717A);
  static const Color deleteBackgroundColor = Color(0xFFFFDDDD);
  static const Color deleteTextColor = Color(0xFFFF6B6B);
  static const Color alarmActiveColor = Color(0xFF5263F3);
  
  // Category colors - selected state background
  static const Color selectedTabBackground = Color(0xFF5263F3);
  static const Color selectedTabTextColor = Color(0xFFEEF3FF);
  
  // Category colors - default state
  static const Color allCategoryText = Color(0xFF5263F3);
  static const Color allCategoryBackground = Color(0xFFDFEAFF);
  
  // Category specific colors
  static const Color akademikText = Color(0xFF3498DB);
  static const Color akademikBackground = Color(0xFFDFEAFF);
  
  static const Color hiburanText = Color(0xFF9B59B6);
  static const Color hiburanBackground = Color(0xFFF0DBFF);
  
  static const Color pekerjaanText = Color(0xFF8E5C42);
  static const Color pekerjaanBackground = Color(0xFFFFE2D3);
  
  static const Color olahragaText = Color(0xFFE74C3C);
  static const Color olahragaBackground = Color(0xFFFFD8D8);
  
  static const Color sosialText = Color(0xFFE67E22);
  static const Color sosialBackground = Color(0xFFFFE3CA);
  
  static const Color spiritualText = Color(0xFF27AE60);
  static const Color spiritualBackground = Color(0xFFD3FFE5);
  
  static const Color pribadiText = Color(0xFFF1C40F);
  static const Color pribadiBackground = Color(0xFFFFF3C2);
  
  static const Color istirahatText = Color(0xFF283593);
  static const Color istirahatBackground = Color(0xFFD2D8FF);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      TextTheme(
        displayLarge: const TextStyle(color: lightTextColor),
        displayMedium: const TextStyle(color: lightTextColor),
        displaySmall: const TextStyle(color: lightTextColor),
        headlineMedium: const TextStyle(color: lightTextColor),
        headlineSmall: const TextStyle(color: lightTextColor),
        titleLarge: const TextStyle(
          color: lightTextColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: const TextStyle(color: lightTextColor),
        titleSmall: const TextStyle(color: lightTextColor),
        bodyLarge: const TextStyle(color: lightTextColor),
        bodyMedium: const TextStyle(color: lightTextColor),
        bodySmall: const TextStyle(color: lightSecondaryTextColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      hintStyle: TextStyle(color: lightSecondaryTextColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    dividerTheme: const DividerThemeData(
      color: lightDividerColor,
      thickness: 1,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: lightCardColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    colorScheme: ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: accentColor,
      surface: lightCardColor,
      onPrimary: Colors.white,
      onSurface: lightTextColor,
      brightness: Brightness.light,
    ),
    iconTheme: const IconThemeData(color: lightTextColor),
  );
}
