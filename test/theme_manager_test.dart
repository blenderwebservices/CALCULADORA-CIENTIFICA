import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scientific_matrix_calculator/models/app_theme_models.dart';
import 'package:scientific_matrix_calculator/utils/theme_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemes Model & Registry Tests', () {
    test('Registra exactamente 8 temas (6 modelos Casio + 2 clásicos)', () {
      expect(AppThemes.allThemes.length, equals(8));
      
      final casioThemes = AppThemes.allThemes.where((t) => t.category == 'Colección Casio').toList();
      final classicThemes = AppThemes.allThemes.where((t) => t.category != 'Colección Casio').toList();
      
      expect(casioThemes.length, equals(6));
      expect(classicThemes.length, equals(2));
    });

    test('Todos los temas tienen configuraciones completas y válidas', () {
      for (final theme in AppThemes.allThemes) {
        expect(theme.name, isNotEmpty);
        expect(theme.subtitle, isNotEmpty);
        expect(theme.backgroundGradients.length, greaterThanOrEqualTo(2));
        expect(theme.glowColors, isNotEmpty);
        expect(theme.scaffoldBackground, isNotNull);
        expect(theme.lcdBackground, isNotNull);
        expect(theme.lcdTextColor, isNotNull);
        expect(theme.numButtonBg, isNotNull);
        expect(theme.numButtonText, isNotNull);
        expect(theme.sciButtonBg, isNotNull);
        expect(theme.opButtonBg, isNotNull);
        expect(theme.acButtonBg, isNotNull);
        expect(theme.delButtonBg, isNotNull);
        expect(theme.equalsButtonBg, isNotNull);
      }
    });

    test('Convierte entre AppThemeId y llaves de persistencia correctamente', () {
      for (final id in AppThemeId.values) {
        final key = AppThemes.toKey(id);
        final restored = AppThemes.fromKey(key);
        expect(restored, equals(id));
      }

      // Claves desconocidas caen a classicDark por defecto
      expect(AppThemes.fromKey('unknown_key'), equals(AppThemeId.classicDark));
      expect(AppThemes.fromKey(null), equals(AppThemeId.classicDark));
    });

    test('toThemeData genera un ThemeData de Flutter funcional', () {
      final theme = AppThemes.casioFx991es;
      final themeData = theme.toThemeData();
      
      expect(themeData.brightness, equals(Brightness.dark));
      expect(themeData.scaffoldBackgroundColor, equals(theme.scaffoldBackground));
      expect(themeData.colorScheme.primary, equals(theme.primaryAccent));
    });
  });

  group('ThemeManager State & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Estado por defecto es classicDark', () {
      final manager = ThemeManager();
      expect(manager.currentThemeId, equals(AppThemeId.classicDark));
      expect(manager.currentTheme.name, contains('Oscuro'));
      expect(manager.themeMode, equals(ThemeMode.dark));
    });

    test('Cambio a Casio fx-991ES Plus actualiza tema y notifica listeners', () async {
      final manager = ThemeManager();
      bool notified = false;
      manager.addListener(() => notified = true);

      await manager.setAppTheme(AppThemeId.casioFx991es);

      expect(manager.currentThemeId, equals(AppThemeId.casioFx991es));
      expect(manager.currentTheme.name, contains('fx-991ES PLUS'));
      expect(manager.currentTheme.isAuthenticLcd, isTrue);
      expect(manager.themeMode, equals(ThemeMode.dark));
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_id'), equals('casio_fx991es'));
    });

    test('Cambio a DEXIN Rosa Pastel actualiza a tema claro', () async {
      final manager = ThemeManager();

      await manager.setAppTheme(AppThemeId.casioPastelPink);

      expect(manager.currentThemeId, equals(AppThemeId.casioPastelPink));
      expect(manager.currentTheme.name, contains('Rosa Pastel'));
      expect(manager.currentTheme.isDark, isFalse);
      expect(manager.themeMode, equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_id'), equals('casio_pastel_pink'));
    });

    test('loadTheme recupera la preferencia guardada en SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_id': 'casio_sky_blue',
      });

      final manager = ThemeManager();
      await manager.loadTheme();

      expect(manager.currentThemeId, equals(AppThemeId.casioSkyBlue));
      expect(manager.currentTheme.name, contains('Azul Cielo'));
      expect(manager.currentTheme.isDark, isFalse);
    });
  });
}
