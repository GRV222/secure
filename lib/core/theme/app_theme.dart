import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TraditionalTheme {
  TraditionalTheme._();

  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.tradBg,
        canvasColor: AppColors.tradBg,
        cardColor: Colors.white,
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.tradSurface),
        colorScheme: const ColorScheme.light(
          primary: AppColors.tradPrimary,
          onPrimary: Color(0xFFFFF5EE),
          secondary: AppColors.tradGold,
          onSecondary: Colors.white,
          surface: AppColors.tradSurface,
          onSurface: AppColors.tradText,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.tradBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.tradBg,
          foregroundColor: AppColors.tradText,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: 'CormorantGaramond',
            color: AppColors.tradText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tradPrimary,
            foregroundColor: const Color(0xFFFFF5EE),
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.tradPrimary,
            foregroundColor: const Color(0xFFFFF5EE),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.tradPrimary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.tradPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.tradPrimary,
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.tradSurface,
          labelStyle: const TextStyle(color: AppColors.tradTextSub),
          hintStyle: const TextStyle(color: AppColors.tradTextSub),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.tradBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.tradBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.tradPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge:   TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.tradText, fontWeight: FontWeight.w700),
          displayMedium:  TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.tradText, fontWeight: FontWeight.w700),
          displaySmall:   TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.tradText, fontWeight: FontWeight.w600),
          headlineLarge:  TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.tradText, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.tradText, fontWeight: FontWeight.w600),
          titleLarge:     TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.tradText, fontWeight: FontWeight.w700),
          titleMedium:    TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradText, fontWeight: FontWeight.w600),
          titleSmall:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradText, fontWeight: FontWeight.w600),
          bodyLarge:      TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradText),
          bodyMedium:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradText),
          bodySmall:      TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradTextSub),
          labelLarge:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradText,    fontWeight: FontWeight.w600),
          labelMedium:    TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradTextSub),
          labelSmall:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.tradTextSub),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.tradBg,
          indicatorColor: AppColors.tradPrimary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.tradPrimary : AppColors.tradTextSub,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.tradPrimary : AppColors.tradTextSub,
            );
          }),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.tradBorder.withValues(alpha: 0.7),
        ),
        iconTheme: const IconThemeData(color: AppColors.tradText),
      );
}

class DigitalTheme {
  DigitalTheme._();

  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.digBg,
        canvasColor: AppColors.digBg,
        cardColor: AppColors.digSurface,
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.digSurface),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.digAccent,
          onPrimary: AppColors.digPorcelain,
          secondary: AppColors.digGold,
          onSecondary: AppColors.digPorcelain,
          surface: AppColors.digSurface,
          onSurface: AppColors.digText,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.digBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.digBg,
          foregroundColor: AppColors.digPorcelain,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: 'CormorantGaramond',
            color: AppColors.digPorcelain,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.digSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.digAccent,
            foregroundColor: AppColors.digPorcelain,
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.digAccent,
            foregroundColor: AppColors.digPorcelain,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.digAccent,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.digAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.digAccent,
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.digCard,
          labelStyle: const TextStyle(color: AppColors.digTextSub),
          hintStyle: const TextStyle(color: AppColors.digTextSub),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.digBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.digBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.digAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge:   TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.digText, fontWeight: FontWeight.w700),
          displayMedium:  TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.digText, fontWeight: FontWeight.w700),
          displaySmall:   TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.digText, fontWeight: FontWeight.w600),
          headlineLarge:  TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.digText, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.digText, fontWeight: FontWeight.w600),
          titleLarge:     TextStyle(fontFamily: 'CormorantGaramond', color: AppColors.digText, fontWeight: FontWeight.w700),
          titleMedium:    TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digText, fontWeight: FontWeight.w600),
          titleSmall:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digText, fontWeight: FontWeight.w600),
          bodyLarge:      TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digText),
          bodyMedium:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digText),
          bodySmall:      TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digTextSub),
          labelLarge:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digText,    fontWeight: FontWeight.w600),
          labelMedium:    TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digTextSub),
          labelSmall:     TextStyle(fontFamily: 'PlusJakartaSans',   color: AppColors.digTextSub),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.digBgDark,
          indicatorColor: AppColors.digPrimary.withValues(alpha: 0.25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.digAccent : AppColors.digTextSub,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.digAccent : AppColors.digTextSub,
            );
          }),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.digBgDark,
          selectedItemColor: AppColors.digAccent,
          unselectedItemColor: AppColors.digTextLight,
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.digBorder.withValues(alpha: 0.8),
        ),
        iconTheme: const IconThemeData(color: AppColors.digText),
      );
}

// Backward-compat wrapper
class AppTheme {
  AppTheme._();
  static ThemeData get traditionalTheme => TraditionalTheme.theme();
  static ThemeData get digitalTheme     => DigitalTheme.theme();
}
