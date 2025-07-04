import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.light;

  ThemeMode get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _currentTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _currentTheme =
        _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _currentTheme == ThemeMode.dark);

    notifyListeners();
  }

  Future<void> setTheme(ThemeMode theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', theme == ThemeMode.dark);

      notifyListeners();
    }
  }
}
