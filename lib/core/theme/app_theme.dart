import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF5263F3);  // Primary blue color
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
        titleLarge: const TextStyle(color: lightTextColor, fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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