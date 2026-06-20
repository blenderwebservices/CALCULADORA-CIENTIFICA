import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/calculator_state.dart';
import 'scientific_screen.dart';
import 'matrix_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final CalculatorState _state = CalculatorState();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo de gradiente oscuro
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0C1B), // Deep dark indigo
            Color(0xFF07050E), // Very dark black-purple
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlows(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                  const Color(0xFF7C3AED).withOpacity(0.18), // Violet
                  const Color(0xFF7C3AED).withOpacity(0.0),
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
                  const Color(0xFF4F46E5).withOpacity(0.22), // Indigo
                  const Color(0xFF4F46E5).withOpacity(0.0),
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
                  const Color(0xFFEC4899).withOpacity(0.12), // Pink/Magenta
                  const Color(0xFFEC4899).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Calculadora ',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.white,
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
        Text(
          'Herramientas matemáticas avanzadas con interfaz táctil premium',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.white38,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
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
        // Columna 3: Historial (Fijo)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: HistoryScreen(state: _state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Barra de pestañas glassmorphic personalizada
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            labelColor: const Color(0xFFC084FC), // soft purple
            unselectedLabelColor: Colors.white60,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Científica'),
              Tab(text: 'Matrices 2x2'),
              Tab(text: 'Historial'),
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
            ],
          ),
        ),
      ],
    );
  }
}
