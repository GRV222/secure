import 'package:flutter/material.dart';

class DigitalTheme {
  DigitalTheme._();

  static const Color primary = Color(0xFF00D4FF);
  static const Color secondary = Color(0xFF7B2FBE);
  static const Color accent = Color(0xFF00FF88);
  static const Color background = Color(0xFF0A0A1A);
  static const Color surface = Color(0xFF12122A);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: background,
      );
}
