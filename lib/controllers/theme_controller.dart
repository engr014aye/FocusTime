import 'package:flutter/material.dart';
import '../core/database/app_database.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  ThemeMode _themeMode = ThemeMode.light; // Light theme by default!

  ThemeController._internal();

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    final savedMode = await AppDatabase.instance.getPreference('theme_mode');
    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await AppDatabase.instance.setPreference('theme_mode', 'light');
    } else {
      _themeMode = ThemeMode.dark;
      await AppDatabase.instance.setPreference('theme_mode', 'dark');
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    await AppDatabase.instance.setPreference('theme_mode', dark ? 'dark' : 'light');
    notifyListeners();
  }
}
