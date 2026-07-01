import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color ink = Color(0xFF050505);
  static const Color eggshell = Color(0xFFF3EFE5);
  static const Color paper = Color(0xFFFFFCF4);
  static const Color mutedInk = Color(0xFF5B574F);
  static const Color rice = Color(0xFFE7DDCB);
  static const Color vermilion = Color(0xFFB53A2F);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: vermilion,
      surface: paper,
      onSurface: ink,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: eggshell,
      fontFamily: 'Georgia',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: paper,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 3.2,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: 1.6),
        ),
        labelStyle: TextStyle(color: mutedInk, letterSpacing: 1.4),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: ink),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: paper,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: ink),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: ink,
          fontSize: 40,
          fontWeight: FontWeight.w400,
          letterSpacing: 8,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 30,
          fontWeight: FontWeight.w400,
          letterSpacing: 6,
        ),
        headlineSmall: TextStyle(
          color: ink,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 4,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
        bodyMedium: TextStyle(
          color: mutedInk,
          fontSize: 15,
          height: 1.55,
        ),
        labelLarge: TextStyle(
          color: ink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.6,
        ),
      ),
    );
  }
}
