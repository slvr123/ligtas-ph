import 'package:flutter/material.dart';

class AppTheme {
  static final ColorScheme _darkColors = const ColorScheme.dark(
    primary: Color(0xFFb91c1c),
    secondary: Color(0xFF1f2937),
    error: Colors.redAccent,
  );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: _darkColors,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0c0a09),
        cardColor: const Color(0xFF1f2937),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF111827),
          hintStyle: TextStyle(color: Colors.white60),
        ),
      );
}
