import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        return MaterialApp(
          title: 'Calculadora Científica & Matricial',
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            primaryColor: const Color(0xFF6366F1), // Indigo
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              secondary: Color(0xFF7C3AED),
              surface: Color(0xFFEEF2F6),
            ),
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              ),
              textStyle: const TextStyle(color: Color(0xFF0F0C1B), fontSize: 12),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF07050E),
            primaryColor: const Color(0xFF6366F1), // Indigo
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              secondary: Color(0xFFC084FC),
              surface: Color(0xFF07050E),
            ),
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              textStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

