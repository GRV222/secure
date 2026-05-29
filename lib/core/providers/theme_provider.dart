import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { traditional, digital }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.traditional;

  AppThemeMode get mode => _mode;
  bool get isDigital => _mode == AppThemeMode.digital;
  bool get isTraditional => _mode == AppThemeMode.traditional;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode') ?? 'traditional';
    _mode = saved == 'digital' ? AppThemeMode.digital : AppThemeMode.traditional;
    notifyListeners();
  }

  Future<void> setTraditional() async {
    _mode = AppThemeMode.traditional;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 'traditional');
    notifyListeners();
  }

  Future<void> setDigital() async {
    _mode = AppThemeMode.digital;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 'digital');
    notifyListeners();
  }

  void toggle() {
    if (_mode == AppThemeMode.traditional) {
      setDigital();
    } else {
      setTraditional();
    }
  }
}
