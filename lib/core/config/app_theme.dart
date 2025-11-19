import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF3A5A92),
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
