import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  SharedPreferences? _prefs;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs?.getString('theme_mode') ?? 'light';
    debugPrint('🎨 Loaded theme from storage: $savedTheme');
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    final modeString = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    debugPrint('🎨 Theme toggled to: ${_themeMode.toString()} - Value: $modeString');

    // Notify listeners immediately for UI update
    notifyListeners();
    debugPrint('🎨 Listeners notified! UI should update now.');

    // Then save to persistent storage
    await _prefs?.setString('theme_mode', modeString);
    debugPrint('🎨 Theme saved to SharedPreferences');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeString = mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system';
    debugPrint('🎨 Theme set to: $modeString');

    // Notify listeners immediately for UI update
    notifyListeners();
    debugPrint('🎨 Listeners notified for mode: $_themeMode');

    // Then save to persistent storage
    await _prefs?.setString('theme_mode', modeString);
    debugPrint('🎨 Theme mode saved to SharedPreferences');
  }
}
