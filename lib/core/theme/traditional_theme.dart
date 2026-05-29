import 'package:flutter/material.dart';

class TraditionalTheme {
  TraditionalTheme._();

  static const Color primary = Color(0xFF8B4513);
  static const Color secondary = Color(0xFFD2691E);
  static const Color accent = Color(0xFFFFD700);
  static const Color background = Color(0xFFFDF5E6);
  static const Color surface = Color(0xFFFFFAF0);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'serif',
      );
}
