import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme_models.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  AppThemeId _currentThemeId = AppThemeId.classicDark;
  AppThemeId get currentThemeId => _currentThemeId;
  AppThemeData get currentTheme => AppThemes.getTheme(_currentThemeId);

  ThemeMode _themeMode = ThemeMode.dark; // Default is dark
  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAppTheme = prefs.getString('app_theme_id');
      
      if (savedAppTheme != null && savedAppTheme.isNotEmpty) {
        _currentThemeId = AppThemes.fromKey(savedAppTheme);
        _themeMode = currentTheme.isDark ? ThemeMode.dark : ThemeMode.light;
      } else {
        final savedTheme = prefs.getString('theme_mode');
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
          _currentThemeId = AppThemeId.classicLight;
        } else if (savedTheme == 'system') {
          _themeMode = ThemeMode.system;
          _currentThemeId = AppThemeId.classicDark;
        } else {
          _themeMode = ThemeMode.dark;
          _currentThemeId = AppThemeId.classicDark;
        }
      }
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      // Ignorar errores
    }
  }

  Future<void> setAppTheme(AppThemeId id) async {
    _currentThemeId = id;
    final themeData = AppThemes.getTheme(id);
    _themeMode = themeData.isDark ? ThemeMode.dark : ThemeMode.light;
    _updateSystemUI();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme_id', AppThemes.toKey(id));
      await prefs.setString('theme_mode', themeData.isDark ? 'dark' : 'light');
    } catch (e) {
      // Ignorar
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    if (mode == ThemeMode.light) {
      _currentThemeId = AppThemeId.classicLight;
    } else {
      _currentThemeId = AppThemeId.classicDark;
    }
    _updateSystemUI();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme_id', AppThemes.toKey(_currentThemeId));
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
    final theme = currentTheme;
    final isDark = theme.isDark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.scaffoldBackground,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }
}
