import 'package:flutter/material.dart';
import 'models/app_theme_models.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  runApp(const ScientificMatrixCalculatorApp());
}

class ScientificMatrixCalculatorApp extends StatelessWidget {
  const ScientificMatrixCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        final activeTheme = themeManager.currentTheme;

        return MaterialApp(
          title: 'Calculadora Científica & Matricial',
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: activeTheme.isDark ? AppThemes.classicLight.toThemeData() : activeTheme.toThemeData(),
          darkTheme: activeTheme.isDark ? activeTheme.toThemeData() : AppThemes.classicDark.toThemeData(),
          home: const SplashScreen(),
        );
      },
    );
  }
}

