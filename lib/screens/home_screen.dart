import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_config.dart';
import '../utils/calculator_state.dart';
import '../utils/theme_manager.dart';
import 'scientific_screen.dart';
import 'matrix_screen.dart';
import 'history_screen.dart';
import 'manual_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final CalculatorState _state = CalculatorState();
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDesktopRightPanel = 0; // 0 para Historial, 1 para Manual

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // 1. Fondo de gradiente oscuro/claro
          _buildBackgroundGradient(),
          // 2. Esferas decorativas difusas (Efecto Glassmorphism)
          _buildBackgroundGlows(context),
          // 3. Contenido de la Aplicación
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado
                  _buildHeader(),
                  const SizedBox(height: 16),
                  // Dashboard Responsivo
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 950) {
                          // Vista de Escritorio (Columnas lado a lado)
                          return _buildDesktopLayout();
                        } else {
                          // Vista Móvil (Barra de Pestañas y Vistas alternables)
                          return _buildMobileLayout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [
                  const Color(0xFF0F0C1B), // Deep dark indigo
                  const Color(0xFF07050E), // Very dark black-purple
                ]
              : [
                  const Color(0xFFF3F0FA), // Soft lavender
                  const Color(0xFFE5E7EB), // Soft gray-blue
                ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlows(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Esfera 1 (Púrpura arriba izquierda)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: size.width * 0.45,
            height: size.width * 0.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.18 : 0.12), // Violet
                  const Color(0xFF7C3AED).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Esfera 2 (Índigo abajo derecha)
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: size.width * 0.5,
            height: size.width * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: isDark ? 0.22 : 0.12), // Indigo
                  const Color(0xFF4F46E5).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Esfera 3 (Naranja/Rosa centro izquierda)
        Positioned(
          top: size.height * 0.35,
          left: -200,
          child: Container(
            width: size.width * 0.4,
            height: size.width * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEC4899).withValues(alpha: isDark ? 0.12 : 0.08), // Pink/Magenta
                  const Color(0xFFEC4899).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);
    final secondaryText = isDark ? Colors.white38 : Colors.black45;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón del Menú Hamburguesa
            InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(
                  Icons.menu,
                  color: primaryText,
                  size: 20,
                ),
              ),
            ),
            Text(
              'Calculadora ',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: primaryText,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFC084FC), Color(0xFF6366F1)], // Purple to Indigo
              ).createShader(bounds),
              child: Text(
                'Científica & Matricial',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 48.0), // Alinear con el título
          child: Text(
            'Herramientas matemáticas avanzadas con interfaz táctil premium',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: secondaryText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? Colors.white60 : Colors.black54;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Columna 1: Científica (Fijo / Constrained)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: ScientificScreen(state: _state),
        ),
        const SizedBox(width: 20),
        // Columna 2: Matrices (Expanded, centrado)
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: MatrixScreen(state: _state),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Columna 3: Historial / Manual (Fijo con pestaña)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de pestañas para el panel derecho
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDesktopRightPanel = 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedDesktopRightPanel == 0
                                ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Historial',
                            style: GoogleFonts.outfit(
                              fontWeight: _selectedDesktopRightPanel == 0 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                              color: _selectedDesktopRightPanel == 0
                                  ? const Color(0xFFC084FC)
                                  : secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDesktopRightPanel = 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedDesktopRightPanel == 1
                                ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Manual',
                            style: GoogleFonts.outfit(
                              fontWeight: _selectedDesktopRightPanel == 1 ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                              color: _selectedDesktopRightPanel == 1
                                  ? const Color(0xFFC084FC)
                                  : secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido del panel seleccionado
              Expanded(
                child: _selectedDesktopRightPanel == 0
                    ? HistoryScreen(state: _state)
                    : const ManualScreen(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? Colors.white60 : Colors.black54;

    return Column(
      children: [
        // Barra de pestañas glassmorphic personalizada
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)),
            ),
            labelColor: const Color(0xFFC084FC), // soft purple
            unselectedLabelColor: secondaryText,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Científica'),
              Tab(text: 'Matrices 2x2'),
              Tab(text: 'Historial'),
              Tab(text: 'Manual'),
            ],
          ),
        ),
        // Vistas de pestañas
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              ScientificScreen(state: _state),
              MatrixScreen(state: _state),
              HistoryScreen(
                state: _state,
                onTabChangeRequested: (tab) {
                  if (tab == 'scientific') {
                    _tabController.animateTo(0);
                  } else if (tab == 'matrix') {
                    _tabController.animateTo(1);
                  }
                },
              ),
              const ManualScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final themeManager = ThemeManager();
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Drawer(
          backgroundColor: isDark ? const Color(0xFF0F0C1B) : const Color(0xFFF3F4F6),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFC084FC), Color(0xFF6366F1)],
                            ).createShader(bounds),
                            child: Text(
                              'Ajustes',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Personaliza tu experiencia matemática',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                const SizedBox(height: 16),
                
                // Título de la sección de tema
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'APARIENCIA / TEMA',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white30 : Colors.black38,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                // Opciones de tema
                _buildThemeOption(
                  context: context,
                  title: 'Modo Claro',
                  icon: Icons.light_mode_outlined,
                  mode: ThemeMode.light,
                  currentMode: themeManager.themeMode,
                  onTap: () => themeManager.setThemeMode(ThemeMode.light),
                ),
                _buildThemeOption(
                  context: context,
                  title: 'Modo Oscuro',
                  icon: Icons.dark_mode_outlined,
                  mode: ThemeMode.dark,
                  currentMode: themeManager.themeMode,
                  onTap: () => themeManager.setThemeMode(ThemeMode.dark),
                ),
                _buildThemeOption(
                  context: context,
                  title: 'Predeterminado del sistema',
                  icon: Icons.brightness_auto_outlined,
                  mode: ThemeMode.system,
                  currentMode: themeManager.themeMode,
                  onTap: () => themeManager.setThemeMode(ThemeMode.system),
                ),
                
                const SizedBox(height: 16),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                const SizedBox(height: 16),
                
                // Título de la sección de preferencias
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'PREFERENCIAS',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white30 : Colors.black38,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                ListenableBuilder(
                  listenable: _state,
                  builder: (context, _) {
                    return _buildSwitchOption(
                      context: context,
                      title: 'Sonido al presionar teclas',
                      icon: Icons.volume_up_outlined,
                      value: AppConfig.clickSoundEnabled,
                      onChanged: (val) {
                        _state.toggleClickSound();
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                const SizedBox(height: 16),
                
                // Título de la sección legal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'LEGAL Y POLÍTICAS',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white30 : Colors.black38,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                _buildDrawerLinkOption(
                  context: context,
                  title: 'Política de Privacidad',
                  icon: Icons.privacy_tip_outlined,
                  url: AppConfig.privacyPolicyUrl,
                ),
                _buildDrawerLinkOption(
                  context: context,
                  title: 'Términos y Condiciones',
                  icon: Icons.description_outlined,
                  url: AppConfig.termsAndConditionsUrl,
                ),
                
                const Spacer(),
                // Información de la versión
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Calculadora Científica & Matricial\nVersión 1.0.0',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? Colors.white24 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          onTap();
          // Cerrar Drawer después de seleccionar la opción
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFC084FC)
                    : (isDark ? Colors.white70 : Colors.black54),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFFC084FC)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFC084FC),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerLinkOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String url,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          try {
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!launched && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No se pudo abrir el enlace: $url')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al abrir el enlace: $url')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: isDark ? Colors.white30 : Colors.black26,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFFC084FC),
              activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
              inactiveThumbColor: isDark ? Colors.white38 : Colors.black38,
              inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ],
        ),
      ),
    );
  }
}
