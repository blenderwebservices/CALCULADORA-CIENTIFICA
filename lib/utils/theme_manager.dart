import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.dark; // Default is dark
  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.dark; // Default
      }
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      // Ignorar errores
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateSystemUI();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.light) {
        await prefs.setString('theme_mode', 'light');
      } else if (mode == ThemeMode.system) {
        await prefs.setString('theme_mode', 'system');
      } else {
        await prefs.setString('theme_mode', 'dark');
      }
    } catch (e) {
      // Ignorar
    }
  }

  void _updateSystemUI() {
    Brightness brightness;
    if (_themeMode == ThemeMode.system) {
      brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    } else {
      brightness = _themeMode == ThemeMode.light ? Brightness.light : Brightness.dark;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
      statusBarBrightness: brightness == Brightness.light ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: brightness == Brightness.light ? const Color(0xFFEEF2F6) : const Color(0xFF07050E),
      systemNavigationBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
    ));
  }
}
