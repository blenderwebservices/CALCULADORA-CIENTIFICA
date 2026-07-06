import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  int _expandedIndex = 0; // Por defecto expandir el primero (%)

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'El Operador de Módulo (%)',
      'icon': Icons.percent,
      'color': Colors.purpleAccent,
      'content': [
        {'type': 'warning', 'text': 'El símbolo % NO calcula porcentaje tradicional. No sirve para hacer operaciones como 50% = 0.5 o 100 + 10%.'},
        {'type': 'text', 'text': 'Es el operador de Módulo, que calcula el residuo de una división entera.'},
        {'type': 'subtitle', 'text': 'Sintaxis (Operador Binario):'},
        {'type': 'formula', 'text': 'A % B'},
        {'type': 'example', 'expr': '10 % 3', 'res': '1.0', 'desc': 'Porque 10 / 3 = 3 y sobra 1.'},
        {'type': 'example', 'expr': '5 % 2', 'res': '1.0', 'desc': 'Porque 5 / 2 = 2 y sobra 1.'},
        {'type': 'subtitle', 'text': 'Cómo calcular porcentajes:'},
        {'type': 'text', 'text': 'Usa operaciones aritméticas tradicionales:'},
        {'type': 'example', 'expr': '200 * 15 / 100', 'res': '30.0', 'desc': 'Para calcular el 15% de 200.'},
        {'type': 'example', 'expr': '150 * 1.10', 'res': '165.0', 'desc': 'Para sumarle el 10% a 150.'},
      ]
    },
    {
      'title': 'Operadores Básicos',
      'icon': Icons.calculate_outlined,
      'color': Colors.blueAccent,
      'content': [
        {'type': 'text', 'text': 'Operaciones aritméticas clásicas de dos operandos:'},
        {'type': 'example', 'expr': 'A + B', 'res': 'Suma', 'desc': 'Ej: 12.5 + 7.5 = 20.0 (También signo unario: +5)'},
        {'type': 'example', 'expr': 'A - B', 'res': 'Resta', 'desc': 'Ej: 15 - 8 = 7.0 (También signo unario: -5)'},
        {'type': 'example', 'expr': 'A * B', 'res': 'Multiplicación', 'desc': 'Se muestra como ×. Ej: 6 * 7 = 42.0'},
        {'type': 'example', 'expr': 'A / B', 'res': 'División', 'desc': 'Se muestra como ÷. Lanza error si B = 0.'},
      ]
    },
    {
      'title': 'Potencias y Factorial',
      'icon': Icons.bolt,
      'color': Colors.amber,
      'content': [
        {'type': 'subtitle', 'text': 'Potenciación (^):'},
        {'type': 'text', 'text': 'Eleva el operando izquierdo a la potencia del derecho.'},
        {'type': 'example', 'expr': '2 ^ 3', 'res': '8.0', 'desc': '2 elevado al cubo.'},
        {'type': 'example', 'expr': '9 ^ 0.5', 'res': '3.0', 'desc': 'Raíz cuadrada de 9.'},
        {'type': 'subtitle', 'text': 'Factorial (!):'},
        {'type': 'text', 'text': 'Multiplica un entero por sus enteros positivos menores (unario posfijo).'},
        {'type': 'example', 'expr': '5!', 'res': '120.0', 'desc': '5 × 4 × 3 × 2 × 1.'},
        {'type': 'warning', 'text': 'Límites del factorial:\n1. Debe ser un número entero.\n2. Debe ser no negativo (>= 0).\n3. Debe ser menor o igual a 170.'},
      ]
    },
    {
      'title': 'Multiplicación Implícita',
      'icon': Icons.star_border,
      'color': Colors.greenAccent,
      'content': [
        {'type': 'text', 'text': 'El motor de la calculadora inserta automáticamente la multiplicación (×) en:'},
        {'type': 'example', 'expr': '2pi', 'res': '2 * pi', 'desc': 'Número seguido de constante.'},
        {'type': 'example', 'expr': '2(3+4)', 'res': '2 * (3+4)', 'desc': 'Número seguido de paréntesis.'},
        {'type': 'example', 'expr': '2sin(30)', 'res': '2 * sin(30)', 'desc': 'Número seguido de función.'},
        {'type': 'example', 'expr': '(2+3)(4+5)', 'res': '(2+3) * (4+5)', 'desc': 'Paréntesis seguido de paréntesis.'},
      ]
    },
    {
      'title': 'Constantes Científicas',
      'icon': Icons.functions,
      'color': Colors.pinkAccent,
      'content': [
        {'type': 'text', 'text': 'Valores fijos de alta precisión integrados:'},
        {'type': 'example', 'expr': 'pi o π', 'res': '3.1415926535...', 'desc': 'Relación diámetro-circunferencia.'},
        {'type': 'example', 'expr': 'e', 'res': '2.7182818284...', 'desc': 'Base de logaritmo natural.'},
      ]
    },
    {
      'title': 'Funciones Científicas',
      'icon': Icons.science_outlined,
      'color': Colors.tealAccent,
      'content': [
        {'type': 'info', 'text': 'Modo de Ángulo (DEG / RAD):\nLas funciones trigonométricas usan Grados (DEG) o Radianes (RAD). Cambia este modo desde la pantalla principal.'},
        {'type': 'subtitle', 'text': 'Trigonométricas:'},
        {'type': 'example', 'expr': 'sin(x), cos(x), tan(x)', 'res': 'Directas', 'desc': 'Ej: sin(30) en DEG = 0.5. tan(90) en DEG da error.'},
        {'type': 'example', 'expr': 'asin(x), acos(x), atan(x)', 'res': 'Inversas', 'desc': 'Ej: asin(0.5) en DEG = 30.0. Dominios asin/acos restringidos a [-1, 1].'},
        {'type': 'subtitle', 'text': 'Logarítmicas y Raíces:'},
        {'type': 'example', 'expr': 'ln(x)', 'res': 'Log. Natural', 'desc': 'Base e. Requiere x > 0.'},
        {'type': 'example', 'expr': 'log(x)', 'res': 'Log. Común', 'desc': 'Base 10. Requiere x > 0.'},
        {'type': 'example', 'expr': 'sqrt(x)', 'res': 'Raíz Cuadrada', 'desc': 'Requiere x >= 0.'},
      ]
    },
    {
      'title': 'Operaciones de Matrices',
      'icon': Icons.grid_on,
      'color': Colors.orangeAccent,
      'content': [
        {'type': 'text', 'text': 'Operaciones con Matriz A y B (dimensiones de 1x1 a 2x2):'},
        {'type': 'example', 'expr': 'A + B / A - B', 'res': 'Suma/Resta', 'desc': 'Requiere dimensiones idénticas.'},
        {'type': 'example', 'expr': 'A × B', 'res': 'Multiplicación', 'desc': 'Columnas de A deben coincidir con filas de B.'},
        {'type': 'example', 'expr': 'det(A) / det(B)', 'res': 'Determinante', 'desc': 'Solo para matrices cuadradas.'},
        {'type': 'example', 'expr': 'Inv(A) / Inv(B)', 'res': 'Inversa', 'desc': 'Matriz cuadrada con determinante diferente de cero.'},
        {'type': 'example', 'expr': 'Trans(A) / Trans(B)', 'res': 'Transpuesta', 'desc': 'Intercambia filas por columnas.'},
        {'type': 'example', 'expr': 'k * A / k * B', 'res': 'Escalar', 'desc': 'Multiplica cada celda por una constante k.'},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado
        Text(
          'Manual de Sintaxis',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 12),
        // Lista de secciones
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final isExpanded = _expandedIndex == index;
              final iconColor = section['color'] as Color;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  child: Column(
                    children: [
                      // Cabecera clicable
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? -1 : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: iconColor.withValues(alpha: isDark ? 0.3 : 0.15)),
                                ),
                                child: Icon(
                                  section['icon'] as IconData,
                                  color: iconColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  section['title'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: isDark ? Colors.white30 : Colors.black38,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Contenido expandible
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _buildSectionContent(section['content'] as List<Map<String, String>>, context),
                          ),
                        ),
                        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionContent(List<Map<String, String>> content, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);
    final secondaryText = isDark ? Colors.white70 : Colors.black87;

    return content.map((item) {
      final type = item['type']!;
      final text = item['text'] ?? '';

      switch (type) {
        case 'text':
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, color: secondaryText, height: 1.35),
            ),
          );
        case 'subtitle':
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: primaryText),
            ),
          );
        case 'formula':
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: const Color(0xFFC084FC),
              ),
            ),
          );
        case 'warning':
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ),
              ],
            ),
          );
        case 'info':
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.blue.shade200 : Colors.blue.shade800, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ),
              ],
            ),
          );
        case 'example':
          final expr = item['expr']!;
          final res = item['res']!;
          final desc = item['desc']!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        expr,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC084FC),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_right_alt, size: 14, color: Colors.grey),
                    Text(
                      ' $res',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
                if (desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2, bottom: 4),
                    child: Text(
                      desc,
                      style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white38 : Colors.black54),
                    ),
                  ),
              ],
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    }).toList();
  }
}
