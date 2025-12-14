// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Palette A1: Light Blue + Leaf Green
  static const Color _blue = Color(0xFF3A86FF);
  static const Color _green = Color(0xFF2ECC71);
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFF7FBFF);
  static const Color _mutedText = Color(0xFF5B6B75);
  static const Color _card = Color(0xFFFFFFFF);
  static const double _radius = 12.0;

  // Primary gradient used in some buttons
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [_blue, _green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Light theme (default)
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _blue, primary: _blue, secondary: _green),
        primaryColor: _blue,

        // AppBar
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: _bg,
          foregroundColor: Colors.black87,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),

        // Text
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12, color: _mutedText),
        ),

        // Elevated / Primary button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            elevation: MaterialStateProperty.resolveWith<double>((states) => 6),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14, horizontal: 18)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            backgroundColor: MaterialStateProperty.all(_blue),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),

        // Outlined button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 14)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            side: MaterialStateProperty.all(BorderSide(color: _blue.withOpacity(0.14))),
            foregroundColor: MaterialStateProperty.all(_blue),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(_blue),
            textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),

        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          hintStyle: const TextStyle(color: Color(0xFF9AA8B0)),
        ),

        // NOTE: avoid assigning CardTheme here to keep compatibility with different Flutter SDKs

        // Icon theme
        iconTheme: const IconThemeData(size: 20, color: Colors.black87),

        // Floating action button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 8,
          foregroundColor: Colors.white,
          backgroundColor: _blue,
        ),

        // Bottom sheet / modal surfaces
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(color: Color(0xFFE6EEF5), thickness: 1),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _blue,
          contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // Dark theme (simple counterpart)
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(seedColor: _green, brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF07101A), foregroundColor: Colors.white),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      );

  // Reusable small helpers
  static Color get primary => _blue;
  static Color get accent => _green;
  static Color get background => _bg;
  static Color get cardColor => _card;
  static BorderRadius borderRadius([double r = _radius]) => BorderRadius.circular(r);
}
