import 'package:flutter/material.dart';

/// Identificador de los temas visuales disponibles en la aplicación
enum AppThemeId {
  // Temas Clásicos de la Suite
  classicDark,
  classicLight,

  // Colección de Calculadoras Casio (Inspirada en modelos físicos reales)
  casioFx991es,        // Foto 1: Casio fx-991ES PLUS (2nd Edition) - Negro mate, LCD Natural V.P.A.M.
  casioGraphite,       // Foto 2: M&G / Casio Gris Grafito - Slate oscuro mate con LCD verdoso
  casioPearlWhite,     // Foto 3 Centro: DEXIN KK-82MS-B Blanco Perla - Carcasa blanca y acentos rojos
  casioPastelPink,     // Foto 3 Derecha: DEXIN KK-82MS-B Rosa Pastel - Rosa suave con acentos frambuesa
  casioSkyBlue,        // Foto 4: KK-82MS-D Azul Cielo - Celeste pastel y teclas blancas con rotulación azul
  casioTranslucentBlue,// Foto 5: Celica CA-83 Azul Translúcido - Estética Y2K cobalto transparente
}

/// Especificación completa de tokens de diseño para un tema de la aplicación
class AppThemeData {
  final AppThemeId id;
  final String name;
  final String subtitle;
  final String category; // 'Colección Casio' o 'Clásico Glassmorphic'
  final bool isDark;
  final IconData icon;

  // Fondo y chasis
  final Color scaffoldBackground;
  final List<Color> backgroundGradients;
  final List<Color> glowColors;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  // Pantalla LCD
  final Color lcdBackground;
  final Color lcdTextColor;
  final Color lcdSecondaryTextColor;
  final Color lcdBorderColor;
  final bool isAuthenticLcd; // Si es true, usa aspecto de cristal líquido retro

  // Teclado (Botones de calculadora)
  final Color numButtonBg;
  final Color numButtonText;
  final Color sciButtonBg;
  final Color sciButtonText;
  final Color opButtonBg;
  final Color opButtonText;
  final Color acButtonBg;
  final Color acButtonText;
  final Color delButtonBg;
  final Color delButtonText;
  final Color equalsButtonBg;
  final Color equalsButtonText;
  final Color utilityButtonBg;
  final Color utilityButtonText;

  // Tarjetas y Glass Containers
  final Color cardBackground;
  final Color cardBorderColor;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.isDark,
    required this.icon,
    required this.scaffoldBackground,
    required this.backgroundGradients,
    required this.glowColors,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.lcdBackground,
    required this.lcdTextColor,
    required this.lcdSecondaryTextColor,
    required this.lcdBorderColor,
    this.isAuthenticLcd = false,
    required this.numButtonBg,
    required this.numButtonText,
    required this.sciButtonBg,
    required this.sciButtonText,
    required this.opButtonBg,
    required this.opButtonText,
    required this.acButtonBg,
    required this.acButtonText,
    required this.delButtonBg,
    required this.delButtonText,
    required this.equalsButtonBg,
    required this.equalsButtonText,
    required this.utilityButtonBg,
    required this.utilityButtonText,
    required this.cardBackground,
    required this.cardBorderColor,
  });

  /// Genera un ThemeData de Flutter compatible con este tema
  ThemeData toThemeData() {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: primaryAccent,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryAccent,
              secondary: secondaryAccent,
              surface: scaffoldBackground,
            )
          : ColorScheme.light(
              primary: primaryAccent,
              secondary: secondaryAccent,
              surface: scaffoldBackground,
            ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cardBorderColor),
        ),
        textStyle: TextStyle(color: primaryTextColor, fontSize: 12),
      ),
    );
  }
}

/// Catálogo de todos los temas configurados en la aplicación
class AppThemes {
  static const List<AppThemeData> allThemes = [
    // -------------------------------------------------------------------------
    // 1. CASIO fx-991ES PLUS (2nd Edition) - Foto 1
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.casioFx991es,
      name: 'Casio fx-991ES PLUS',
      subtitle: 'Negro mate con visor LCD Natural-V.P.A.M.',
      category: 'Colección Casio',
      isDark: true,
      icon: Icons.calculate,
      scaffoldBackground: Color(0xFF141518),
      backgroundGradients: [Color(0xFF181A1E), Color(0xFF0F1012)],
      glowColors: [Color(0xFF84CC16), Color(0xFFEAB308), Color(0xFF3F3F46)],
      primaryAccent: Color(0xFFEAB308), // Amarillo dorado de SHIFT / Casio logo
      secondaryAccent: Color(0xFF84CC16), // Verde lima Casio DEL
      primaryTextColor: Color(0xFFF4F4F5),
      secondaryTextColor: Color(0xFFA1A1AA),
      // Pantalla LCD auténtica verdosa
      lcdBackground: Color(0xFFC4D4AF),
      lcdTextColor: Color(0xFF13220E),
      lcdSecondaryTextColor: Color(0xFF384E31),
      lcdBorderColor: Color(0xFF869970),
      isAuthenticLcd: true,
      // Teclado
      numButtonBg: Color(0xFFE4E4E7), // Teclas numéricas color plata/gris claro
      numButtonText: Color(0xFF18181B), // Dígitos en negro profundo
      sciButtonBg: Color(0xFF27272A), // Teclas científicas carbón oscuro
      sciButtonText: Color(0xFFFAFAFA),
      opButtonBg: Color(0xFF3F3F46), // Teclas de operaciones gris medio
      opButtonText: Color(0xFFFFFFFF),
      acButtonBg: Color(0xFFDC2626), // AC Rojo coral Casio
      acButtonText: Color(0xFFFFFFFF),
      delButtonBg: Color(0xFF84CC16), // DEL Verde lima Casio
      delButtonText: Color(0xFF14532D),
      equalsButtonBg: Color(0xFFD4D4D8),
      equalsButtonText: Color(0xFF18181B),
      utilityButtonBg: Color(0xFF9CA3AF), // D-Pad plata metalizado
      utilityButtonText: Color(0xFF18181B),
      cardBackground: Color(0x1AFFFFFF),
      cardBorderColor: Color(0x1FFFFFFF),
    ),

    // -------------------------------------------------------------------------
    // 2. CASIO GRIS GRAFITO / SLATE (M&G) - Foto 2
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.casioGraphite,
      name: 'Casio Gris Grafito',
      subtitle: 'Chasis grafito mate con LCD clásico verde cálido',
      category: 'Colección Casio',
      isDark: true,
      icon: Icons.memory,
      scaffoldBackground: Color(0xFF1B2026),
      backgroundGradients: [Color(0xFF232A32), Color(0xFF15191E)],
      glowColors: [Color(0xFF0284C7), Color(0xFF64748B), Color(0xFF0F172A)],
      primaryAccent: Color(0xFF38BDF8),
      secondaryAccent: Color(0xFFF43F5E),
      primaryTextColor: Color(0xFFF1F5F9),
      secondaryTextColor: Color(0xFF94A3B8),
      lcdBackground: Color(0xFFBACBA4),
      lcdTextColor: Color(0xFF142210),
      lcdSecondaryTextColor: Color(0xFF35482F),
      lcdBorderColor: Color(0xFF7A8D68),
      isAuthenticLcd: true,
      numButtonBg: Color(0xFF334155),
      numButtonText: Color(0xFFF8FAFC),
      sciButtonBg: Color(0xFF1E293B),
      sciButtonText: Color(0xFFE2E8F0),
      opButtonBg: Color(0xFF475569),
      opButtonText: Color(0xFFFFFFFF),
      acButtonBg: Color(0xFFBE123C),
      acButtonText: Color(0xFFFFFFFF),
      delButtonBg: Color(0xFFF43F5E),
      delButtonText: Color(0xFFFFFFFF),
      equalsButtonBg: Color(0xFF38BDF8),
      equalsButtonText: Color(0xFF0F172A),
      utilityButtonBg: Color(0xFF64748B),
      utilityButtonText: Color(0xFFFFFFFF),
      cardBackground: Color(0x18FFFFFF),
      cardBorderColor: Color(0x1AFFFFFF),
    ),

    // -------------------------------------------------------------------------
    // 3. CASIO BLANCO PERLA (DEXIN) - Foto 3 Centro
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.casioPearlWhite,
      name: 'Casio Blanco Perla',
      subtitle: 'Blanco perla minimalista con acentos carmesí',
      category: 'Colección Casio',
      isDark: false,
      icon: Icons.lens_blur_outlined,
      scaffoldBackground: Color(0xFFF4F6F9),
      backgroundGradients: [Color(0xFFFFFFFF), Color(0xFFE8EDF2)],
      glowColors: [Color(0xFFE11D48), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
      primaryAccent: Color(0xFFE11D48),
      secondaryAccent: Color(0xFF475569),
      primaryTextColor: Color(0xFF0F172A),
      secondaryTextColor: Color(0xFF64748B),
      lcdBackground: Color(0xFFC0CEB5),
      lcdTextColor: Color(0xFF111E0E),
      lcdSecondaryTextColor: Color(0xFF34452F),
      lcdBorderColor: Color(0xFF94A3B8),
      isAuthenticLcd: true,
      numButtonBg: Color(0xFFFFFFFF),
      numButtonText: Color(0xFF0F172A),
      sciButtonBg: Color(0xFFE2E8F0),
      sciButtonText: Color(0xFF334155),
      opButtonBg: Color(0xFFCBD5E1),
      opButtonText: Color(0xFF0F172A),
      acButtonBg: Color(0xFFE11D48),
      acButtonText: Color(0xFFFFFFFF),
      delButtonBg: Color(0xFFF43F5E),
      delButtonText: Color(0xFFFFFFFF),
      equalsButtonBg: Color(0xFFE2E8F0),
      equalsButtonText: Color(0xFF0F172A),
      utilityButtonBg: Color(0xFFCBD5E1),
      utilityButtonText: Color(0xFF0F172A),
      cardBackground: Color(0xFFFFFFFF),
      cardBorderColor: Color(0x1A000000),
    ),

    // -------------------------------------------------------------------------
    // 4. CASIO ROSA PASTEL (DEXIN) - Foto 3 Derecha
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.casioPastelPink,
      name: 'Casio Rosa Pastel',
      subtitle: 'Rosa blush delicado con detalles frambuesa y LCD cálido',
      category: 'Colección Casio',
      isDark: false,
      icon: Icons.favorite_border_rounded,
      scaffoldBackground: Color(0xFFFDF2F8),
      backgroundGradients: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
      glowColors: [Color(0xFFF472B6), Color(0xFFFB7185), Color(0xFFFDA4AF)],
      primaryAccent: Color(0xFFDB2777),
      secondaryAccent: Color(0xFFBE185D),
      primaryTextColor: Color(0xFF4A044E),
      secondaryTextColor: Color(0xFF831843),
      lcdBackground: Color(0xFFBDCBA5),
      lcdTextColor: Color(0xFF192613),
      lcdSecondaryTextColor: Color(0xFF3F4F37),
      lcdBorderColor: Color(0xFFF472B6),
      isAuthenticLcd: true,
      numButtonBg: Color(0xFFFFFFFF),
      numButtonText: Color(0xFF701A75),
      sciButtonBg: Color(0xFFFCE7F3),
      sciButtonText: Color(0xFF831843),
      opButtonBg: Color(0xFFFBCFE8),
      opButtonText: Color(0xFF701A75),
      acButtonBg: Color(0xFFE11D48),
      acButtonText: Color(0xFFFFFFFF),
      delButtonBg: Color(0xFFFB7185),
      delButtonText: Color(0xFFFFFFFF),
      equalsButtonBg: Color(0xFFDB2777),
      equalsButtonText: Color(0xFFFFFFFF),
      utilityButtonBg: Color(0xFFFBCFE8),
      utilityButtonText: Color(0xFF701A75),
      cardBackground: Color(0xFFFFFFFF),
      cardBorderColor: Color(0x24DB2777),
    ),

    // -------------------------------------------------------------------------
    // 5. CASIO AZUL CIELO (KK-82MS-D) - Foto 4
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.casioSkyBlue,
      name: 'Casio Azul Cielo',
      subtitle: 'Celeste pastel con teclas blancas, texto azul y rojo',
      category: 'Colección Casio',
      isDark: false,
      icon: Icons.water_drop_outlined,
      scaffoldBackground: Color(0xFFF0F9FF),
      backgroundGradients: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
      glowColors: [Color(0xFF38BDF8), Color(0xFF60A5FA), Color(0xFFEF4444)],
      primaryAccent: Color(0xFF0284C7),
      secondaryAccent: Color(0xFFEF4444),
      primaryTextColor: Color(0xFF0C4A6E),
      secondaryTextColor: Color(0xFF0369A1),
      lcdBackground: Color(0xFFBCCBB0),
      lcdTextColor: Color(0xFF111E0E),
      lcdSecondaryTextColor: Color(0xFF354631),
      lcdBorderColor: Color(0xFF38BDF8),
      isAuthenticLcd: true,
      numButtonBg: Color(0xFFFFFFFF),
      numButtonText: Color(0xFF0369A1),
      sciButtonBg: Color(0xFFE0F2FE),
      sciButtonText: Color(0xFF075985),
      opButtonBg: Color(0xFFBAE6FD),
      opButtonText: Color(0xFF0369A1),
      acButtonBg: Color(0xFFEF4444),
      acButtonText: Color(0xFFFFFFFF),
      delButtonBg: Color(0xFFF87171),
      delButtonText: Color(0xFFFFFFFF),
      equalsButtonBg: Color(0xFF0284C7),
      equalsButtonText: Color(0xFFFFFFFF),
      utilityButtonBg: Color(0xFFBAE6FD),
      utilityButtonText: Color(0xFF0369A1),
      cardBackground: Color(0xFFFFFFFF),
      cardBorderColor: Color(0x260284C7),
    ),

    // -------------------------------------------------------------------------
    // 6. CASIO AZUL TRANSLÚCIDO Y2K (Celica CA-83) - Foto 5
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.casioTranslucentBlue,
      name: 'Casio Azul Translúcido',
      subtitle: 'Carcasa translúcida azul cobalto Y2K con alto contraste',
      category: 'Colección Casio',
      isDark: true,
      icon: Icons.blur_on_rounded,
      scaffoldBackground: Color(0xFF0F172A),
      backgroundGradients: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
      glowColors: [Color(0xFF2563EB), Color(0xFF38BDF8), Color(0xFF1D4ED8)],
      primaryAccent: Color(0xFF38BDF8),
      secondaryAccent: Color(0xFF60A5FA),
      primaryTextColor: Color(0xFFF8FAFC),
      secondaryTextColor: Color(0xFF93C5FD),
      lcdBackground: Color(0xFFC5D4BD),
      lcdTextColor: Color(0xFF0E1A0A),
      lcdSecondaryTextColor: Color(0xFF2E3E29),
      lcdBorderColor: Color(0xFF38BDF8),
      isAuthenticLcd: true,
      numButtonBg: Color(0xFFE2E8F0),
      numButtonText: Color(0xFF0F172A),
      sciButtonBg: Color(0x401E3A8A),
      sciButtonText: Color(0xFFBAE6FD),
      opButtonBg: Color(0xFFCBD5E1),
      opButtonText: Color(0xFF0F172A),
      acButtonBg: Color(0xFFDC2626),
      acButtonText: Color(0xFFFFFFFF),
      delButtonBg: Color(0xFFE11D48),
      delButtonText: Color(0xFFFFFFFF),
      equalsButtonBg: Color(0xFF2563EB),
      equalsButtonText: Color(0xFFFFFFFF),
      utilityButtonBg: Color(0xFF1E40AF),
      utilityButtonText: Color(0xFFBAE6FD),
      cardBackground: Color(0x2E1E3A8A),
      cardBorderColor: Color(0x4D38BDF8),
    ),

    // -------------------------------------------------------------------------
    // 7. CLÁSICO OSCURO (Índigo Glassmorphism)
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.classicDark,
      name: 'Clásico Oscuro',
      subtitle: 'Estilo Índigo Profundo con Glassmorphism moderno',
      category: 'Clásicos Glassmorphic',
      isDark: true,
      icon: Icons.dark_mode_outlined,
      scaffoldBackground: Color(0xFF07050E),
      backgroundGradients: [Color(0xFF0F0C1B), Color(0xFF07050E)],
      glowColors: [Color(0xFF7C3AED), Color(0xFF4F46E5), Color(0xFFEC4899)],
      primaryAccent: Color(0xFFC084FC),
      secondaryAccent: Color(0xFF6366F1),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0x80FFFFFF),
      lcdBackground: Color(0x1AFFFFFF),
      lcdTextColor: Color(0xFFFFFFFF),
      lcdSecondaryTextColor: Color(0x80FFFFFF),
      lcdBorderColor: Color(0x1FFFFFFF),
      isAuthenticLcd: false,
      numButtonBg: Color(0x0DFFFFFF),
      numButtonText: Color(0xFFFFFFFF),
      sciButtonBg: Color(0x1F6366F1),
      sciButtonText: Color(0xFFC084FC),
      opButtonBg: Color(0x40F97316),
      opButtonText: Color(0xFFFB923C),
      acButtonBg: Color(0x26F87171),
      acButtonText: Color(0xFFF87171),
      delButtonBg: Color(0x1AFFFFFF),
      delButtonText: Color(0xB3FFFFFF),
      equalsButtonBg: Color(0xFF6366F1),
      equalsButtonText: Color(0xFFFFFFFF),
      utilityButtonBg: Color(0x0DFFFFFF),
      utilityButtonText: Color(0xFFC084FC),
      cardBackground: Color(0x0AFFFFFF),
      cardBorderColor: Color(0x14FFFFFF),
    ),

    // -------------------------------------------------------------------------
    // 8. CLÁSICO CLARO (Lavender Glassmorphism)
    // -------------------------------------------------------------------------
    AppThemeData(
      id: AppThemeId.classicLight,
      name: 'Clásico Claro',
      subtitle: 'Estilo Lavanda Suave con Glassmorphism moderno',
      category: 'Clásicos Glassmorphic',
      isDark: false,
      icon: Icons.light_mode_outlined,
      scaffoldBackground: Color(0xFFF3F4F6),
      backgroundGradients: [Color(0xFFF3F0FA), Color(0xFFE5E7EB)],
      glowColors: [Color(0xFF7C3AED), Color(0xFF4F46E5), Color(0xFFEC4899)],
      primaryAccent: Color(0xFF6366F1),
      secondaryAccent: Color(0xFF7C3AED),
      primaryTextColor: Color(0xFF0F0C1B),
      secondaryTextColor: Color(0x8A000000),
      lcdBackground: Color(0x0A000000),
      lcdTextColor: Color(0xFF0F0C1B),
      lcdSecondaryTextColor: Color(0x8A000000),
      lcdBorderColor: Color(0x14000000),
      isAuthenticLcd: false,
      numButtonBg: Color(0x0A000000),
      numButtonText: Color(0xFF0F0C1B),
      sciButtonBg: Color(0x147C3AED),
      sciButtonText: Color(0xFF7C3AED),
      opButtonBg: Color(0x24EA580C),
      opButtonText: Color(0xFFEA580C),
      acButtonBg: Color(0x1ADC2626),
      acButtonText: Color(0xFFDC2626),
      delButtonBg: Color(0x0D000000),
      delButtonText: Color(0x8A000000),
      equalsButtonBg: Color(0xFF6366F1),
      equalsButtonText: Color(0xFFFFFFFF),
      utilityButtonBg: Color(0x0A000000),
      utilityButtonText: Color(0xFF6366F1),
      cardBackground: Color(0x08000000),
      cardBorderColor: Color(0x0F000000),
    ),
  ];

  /// Obtiene un tema por su ID o retorna el clásico oscuro por defecto
  static AppThemeData getTheme(AppThemeId id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => allThemes[0], // Casio fx-991ES o Clásico Oscuro
    );
  }

  /// Convierte una clave de texto en AppThemeId
  static AppThemeId fromKey(String? key) {
    switch (key) {
      case 'casio_fx991es':
        return AppThemeId.casioFx991es;
      case 'casio_graphite':
        return AppThemeId.casioGraphite;
      case 'casio_pearl_white':
        return AppThemeId.casioPearlWhite;
      case 'casio_pastel_pink':
        return AppThemeId.casioPastelPink;
      case 'casio_sky_blue':
        return AppThemeId.casioSkyBlue;
      case 'casio_translucent_blue':
        return AppThemeId.casioTranslucentBlue;
      case 'classic_light':
        return AppThemeId.classicLight;
      case 'classic_dark':
      default:
        return AppThemeId.classicDark;
    }
  }

  /// Convierte un AppThemeId en su clave persistente
  static String toKey(AppThemeId id) {
    switch (id) {
      case AppThemeId.casioFx991es:
        return 'casio_fx991es';
      case AppThemeId.casioGraphite:
        return 'casio_graphite';
      case AppThemeId.casioPearlWhite:
        return 'casio_pearl_white';
      case AppThemeId.casioPastelPink:
        return 'casio_pastel_pink';
      case AppThemeId.casioSkyBlue:
        return 'casio_sky_blue';
      case AppThemeId.casioTranslucentBlue:
        return 'casio_translucent_blue';
      case AppThemeId.classicLight:
        return 'classic_light';
      case AppThemeId.classicDark:
        return 'classic_dark';
    }
  }

  // Getters de conveniencia
  static AppThemeData get classicDark => getTheme(AppThemeId.classicDark);
  static AppThemeData get classicLight => getTheme(AppThemeId.classicLight);
  static AppThemeData get casioFx991es => getTheme(AppThemeId.casioFx991es);
  static AppThemeData get casioGraphite => getTheme(AppThemeId.casioGraphite);
  static AppThemeData get casioPearlWhite => getTheme(AppThemeId.casioPearlWhite);
  static AppThemeData get casioPastelPink => getTheme(AppThemeId.casioPastelPink);
  static AppThemeData get casioSkyBlue => getTheme(AppThemeId.casioSkyBlue);
  static AppThemeData get casioTranslucentBlue => getTheme(AppThemeId.casioTranslucentBlue);
}
