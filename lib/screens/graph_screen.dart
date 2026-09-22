import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../utils/calculator_state.dart';
import '../utils/math_parser.dart';
import '../utils/matrix_ops.dart';

class GraphScreen extends StatefulWidget {
  final CalculatorState state;

  const GraphScreen({super.key, required this.state});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _exprCtrl = TextEditingController(text: 'sin(x)');
  String _currentExpr = 'sin(x)';
  String _angleMode = 'RAD'; // Por defecto RAD para cálculo diferencial/gráficas
  List<Token>? _compiledPostfix;
  String? _errorMessage;

  // Parámetros de la vista del plano cartesiano
  double _centerX = 0.0;
  double _centerY = 0.0;
  double _scale = 35.0; // Píxeles por unidad matemática

  // Inspección de cursor / puntos táctiles
  Offset? _touchPosition;
  double? _inspectedX;
  double? _inspectedY;

  // Tabla de valores
  bool _showTable = false;

  final List<String> _presets = [
    'sin(x)',
    'cos(x)',
    'tan(x)',
    'x^2 - 4',
    'x^3 - 3*x',
    '1/x',
    'sqrt(x)',
    'e^x',
    'ln(x)',
    'abs(x)',
  ];

  @override
  void initState() {
    super.initState();
    _compileExpression();
  }

  @override
  void dispose() {
    _exprCtrl.dispose();
    super.dispose();
  }

  void _compileExpression() {
    setState(() {
      _currentExpr = _exprCtrl.text.trim();
      if (_currentExpr.isEmpty) {
        _compiledPostfix = null;
        _errorMessage = 'Ingresa una función f(x)';
        return;
      }
      try {
        _compiledPostfix = MathParser.parseToPostfix(_currentExpr);
        // Probar una evaluación de prueba con x = 1
        MathParser.evaluatePostfix(_compiledPostfix!, _angleMode, xValue: 1.0, quietMode: true);
        _errorMessage = null;
      } catch (e) {
        _compiledPostfix = null;
        _errorMessage = 'Sintaxis inválida en f(x)';
      }
    });
  }

  void _resetView() {
    setState(() {
      _centerX = 0.0;
      _centerY = 0.0;
      _scale = 35.0;
      _inspectedX = null;
      _inspectedY = null;
      _touchPosition = null;
    });
  }

  void _zoom(double factor) {
    setState(() {
      _scale = (_scale * factor).clamp(8.0, 300.0);
    });
  }

  void _saveToHistory() {
    if (_compiledPostfix != null) {
      widget.state.addGraphHistoryItem(
        expression: _currentExpr,
        result: 'Graficada [Zoom: ${_scale.toStringAsFixed(0)} px/u, Modo: $_angleMode]',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Función f(x) = $_currentExpr guardada en el historial'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF6366F1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);
    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Graficador de Funciones 2D',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              Row(
                children: [
                  // Conmutador RAD / DEG
                  InkWell(
                    onTap: () {
                      setState(() {
                        _angleMode = _angleMode == 'RAD' ? 'DEG' : 'RAD';
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _angleMode,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC084FC),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _saveToHistory,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bookmark_add_outlined, size: 14, color: Color(0xFFC084FC)),
                          const SizedBox(width: 4),
                          Text(
                            'Guardar',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barra de ingreso de la función
          GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'f(x) = ',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC084FC),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _exprCtrl,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ej: x^2 - 4, sin(x), 2x + 1',
                          hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white30 : Colors.black26),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onSubmitted: (_) => _compileExpression(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _compileExpression,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Graficar', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 10),

                // Presets rápidos
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _presets.map((preset) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () {
                            _exprCtrl.text = preset;
                            _compileExpression();
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                            ),
                            child: Text(
                              preset,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Lienzo de la gráfica
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de herramientas del lienzo (Zoom, Reset, Coordenadas)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06))),
                  ),
                  child: Row(
                    children: [
                      // Badge de Coordenada inspeccionada
                      if (_inspectedX != null && _inspectedY != null && !_inspectedY!.isNaN)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '(x: ${MatrixOps.formatDouble(_inspectedX!)}, y: ${MatrixOps.formatDouble(_inspectedY!)})',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFC084FC),
                            ),
                          ),
                        )
                      else
                        Text(
                          'Toca o arrastra para inspeccionar',
                          style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      const Spacer(),

                      // Botones Zoom Out, Zoom In, Reset
                      _buildCanvasToolBtn(Icons.remove, () => _zoom(0.8), isDark),
                      const SizedBox(width: 4),
                      _buildCanvasToolBtn(Icons.add, () => _zoom(1.25), isDark),
                      const SizedBox(width: 4),
                      _buildCanvasToolBtn(Icons.center_focus_strong, _resetView, isDark, tooltip: 'Centrar (0,0)'),
                      const SizedBox(width: 4),
                      _buildCanvasToolBtn(
                        Icons.table_chart_outlined,
                        () => setState(() => _showTable = !_showTable),
                        isDark,
                        tooltip: 'Tabla de valores',
                        isActive: _showTable,
                      ),
                    ],
                  ),
                ),

                // Área del Canvas
                SizedBox(
                  height: 380,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _centerX -= details.delta.dx / _scale;
                          _centerY += details.delta.dy / _scale;
                          _inspectedX = null;
                          _inspectedY = null;
                          _touchPosition = null;
                        });
                      },
                      onTapDown: (details) {
                        _handleTouch(details.localPosition);
                      },
                      onPanDown: (details) {
                        _handleTouch(details.localPosition);
                      },
                      child: CustomPaint(
                        painter: _GraphPainter(
                          isDark: isDark,
                          centerX: _centerX,
                          centerY: _centerY,
                          scale: _scale,
                          compiledPostfix: _compiledPostfix,
                          angleMode: _angleMode,
                          touchPosition: _touchPosition,
                          inspectedX: _inspectedX,
                          inspectedY: _inspectedY,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tabla de Valores (Opcional si _showTable es true)
          if (_showTable && _compiledPostfix != null)
            _buildValuesTable(isDark, primaryText, secondaryText),
        ],
      ),
    );
  }

  void _handleTouch(Offset localPos) {
    if (_compiledPostfix == null) return;
    final mathX = _centerX + (localPos.dx - 190.0) / _scale; // aproximación o calculada en layout
    final mathY = MathParser.evaluatePostfix(
      _compiledPostfix!,
      _angleMode,
      xValue: mathX,
      quietMode: true,
    );
    setState(() {
      _touchPosition = localPos;
      _inspectedX = mathX;
      _inspectedY = mathY;
    });
  }

  Widget _buildCanvasToolBtn(
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    String? tooltip,
    bool isActive = false,
  }) {
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1).withValues(alpha: 0.25)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1)
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive
              ? const Color(0xFFC084FC)
              : (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }

  Widget _buildValuesTable(bool isDark, Color primaryText, Color secondaryText) {
    final xValues = [-5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0];

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tabla de Valores f(x)',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: primaryText),
              ),
              Text(
                'f(x) = $_currentExpr',
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFC084FC), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text('x', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: primaryText)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Text('f(x)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: primaryText)),
                    ),
                  ),
                ],
              ),
              ...xValues.map((x) {
                final y = MathParser.evaluatePostfix(
                  _compiledPostfix!,
                  _angleMode,
                  xValue: x,
                  quietMode: true,
                );
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Text(
                          x % 1 == 0 ? x.toInt().toString() : x.toString(),
                          style: GoogleFonts.outfit(fontSize: 12, color: secondaryText),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Text(
                          y.isNaN || y.isInfinite ? 'Indefinido' : MatrixOps.formatDouble(y),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: y.isNaN || y.isInfinite ? Colors.redAccent : const Color(0xFFC084FC),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// CUSTOM PAINTER: PLANO CARTESIANO Y CURVA DE LA FUNCIÓN
// =====================================================================
class _GraphPainter extends CustomPainter {
  final bool isDark;
  final double centerX;
  final double centerY;
  final double scale;
  final List<Token>? compiledPostfix;
  final String angleMode;
  final Offset? touchPosition;
  final double? inspectedX;
  final double? inspectedY;

  _GraphPainter({
    required this.isDark,
    required this.centerX,
    required this.centerY,
    required this.scale,
    required this.compiledPostfix,
    required this.angleMode,
    this.touchPosition,
    this.inspectedX,
    this.inspectedY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double originScreenX = (size.width / 2.0) - (centerX * scale);
    final double originScreenY = (size.height / 2.0) + (centerY * scale);

    _drawGrid(canvas, size, originScreenX, originScreenY);
    _drawAxes(canvas, size, originScreenX, originScreenY);

    if (compiledPostfix != null) {
      _drawFunctionCurve(canvas, size, originScreenX, originScreenY);
    }

    if (inspectedX != null && inspectedY != null && !inspectedY!.isNaN && !inspectedY!.isInfinite) {
      _drawCursorPoint(canvas, size, originScreenX, originScreenY);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double originX, double originY) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    // Determinar espaciado de cuadrícula adaptativo
    double stepMath = 1.0;
    if (scale < 15.0) stepMath = 5.0;
    if (scale < 8.0) stepMath = 10.0;
    if (scale > 70.0) stepMath = 0.5;
    if (scale > 150.0) stepMath = 0.2;

    final double stepPixels = stepMath * scale;

    // Líneas verticales
    double x = originX % stepPixels;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      x += stepPixels;
    }

    // Líneas horizontales
    double y = originY % stepPixels;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      y += stepPixels;
    }
  }

  void _drawAxes(Canvas canvas, Size size, double originX, double originY) {
    final axisPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;

    // Eje X
    if (originY >= 0 && originY <= size.height) {
      canvas.drawLine(Offset(0, originY), Offset(size.width, originY), axisPaint);
    }
    // Eje Y
    if (originX >= 0 && originX <= size.width) {
      canvas.drawLine(Offset(originX, 0), Offset(originX, size.height), axisPaint);
    }

    // Etiquetas numéricas de los ejes
    double stepMath = 1.0;
    if (scale < 15.0) stepMath = 5.0;
    if (scale < 8.0) stepMath = 10.0;
    if (scale > 70.0) stepMath = 0.5;

    final double stepPixels = stepMath * scale;
    final textStyle = TextStyle(
      fontSize: 10,
      color: isDark ? Colors.white38 : Colors.black38,
      fontFamily: 'Outfit',
    );

    // Ticks y números en Eje X
    double mathVal = -((originX / stepPixels).floor()) * stepMath;
    double currentX = originX + (mathVal / stepMath) * stepPixels;
    while (currentX < size.width) {
      if ((currentX - originX).abs() > 4 && currentX > 10 && currentX < size.width - 20) {
        final tp = TextPainter(
          text: TextSpan(text: mathVal % 1 == 0 ? mathVal.toInt().toString() : mathVal.toStringAsFixed(1), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final textY = (originY + 4).clamp(4.0, size.height - 16.0);
        tp.paint(canvas, Offset(currentX - (tp.width / 2), textY));
      }
      currentX += stepPixels;
      mathVal += stepMath;
    }

    // Ticks y números en Eje Y
    mathVal = ((originY / stepPixels).floor()) * stepMath;
    double currentY = originY - (mathVal / stepMath) * stepPixels;
    while (currentY < size.height) {
      if ((currentY - originY).abs() > 4 && currentY > 10 && currentY < size.height - 20) {
        final tp = TextPainter(
          text: TextSpan(text: mathVal % 1 == 0 ? mathVal.toInt().toString() : mathVal.toStringAsFixed(1), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final textX = (originX + 6).clamp(4.0, size.width - tp.width - 6.0);
        tp.paint(canvas, Offset(textX, currentY - (tp.height / 2)));
      }
      currentY += stepPixels;
      mathVal -= stepMath;
    }
  }

  void _drawFunctionCurve(Canvas canvas, Size size, double originX, double originY) {
    final curvePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFC084FC), Color(0xFF6366F1)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF818CF8).withValues(alpha: isDark ? 0.25 : 0.15)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final List<Path> segments = [];
    Path currentPath = Path();
    bool isSegmentActive = false;
    double? lastY;

    // Muestreo denso pixel por pixel para curva suave
    for (double screenX = 0; screenX <= size.width; screenX += 1.5) {
      final double mathX = (screenX - originX) / scale;
      final double mathY = MathParser.evaluatePostfix(
        compiledPostfix!,
        angleMode,
        xValue: mathX,
        quietMode: true,
      );

      if (mathY.isNaN || mathY.isInfinite) {
        if (isSegmentActive) {
          segments.add(currentPath);
          currentPath = Path();
          isSegmentActive = false;
        }
        lastY = null;
        continue;
      }

      final double screenY = originY - (mathY * scale);

      // Detección de asíntota o salto discontinuo (ej. tan(x), 1/x)
      if (lastY != null && (screenY - lastY).abs() > size.height * 0.85) {
        if (isSegmentActive) {
          segments.add(currentPath);
          currentPath = Path();
          isSegmentActive = false;
        }
      }

      if (!isSegmentActive) {
        currentPath.moveTo(screenX, screenY);
        isSegmentActive = true;
      } else {
        currentPath.lineTo(screenX, screenY);
      }
      lastY = screenY;
    }

    if (isSegmentActive) {
      segments.add(currentPath);
    }

    // Dibujar todos los segmentos suaves sin conectar asíntotas
    for (final seg in segments) {
      canvas.drawPath(seg, glowPaint);
      canvas.drawPath(seg, curvePaint);
    }
  }

  void _drawCursorPoint(Canvas canvas, Size size, double originX, double originY) {
    final double screenX = originX + (inspectedX! * scale);
    final double screenY = originY - (inspectedY! * scale);

    if (screenX >= 0 && screenX <= size.width && screenY >= 0 && screenY <= size.height) {
      // Línea vertical punteada
      final guidePaint = Paint()
        ..color = const Color(0xFFC084FC).withValues(alpha: 0.4)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(screenX, 0), Offset(screenX, size.height), guidePaint);

      // Círculo del punto
      final haloPaint = Paint()
        ..color = const Color(0xFF6366F1).withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(screenX, screenY), 8.0, haloPaint);

      final dotPaint = Paint()
        ..color = const Color(0xFFC084FC)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(screenX, screenY), 4.5, dotPaint);

      final centerWhitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(screenX, screenY), 2.0, centerWhitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.centerY != centerY ||
        oldDelegate.scale != scale ||
        oldDelegate.compiledPostfix != compiledPostfix ||
        oldDelegate.angleMode != angleMode ||
        oldDelegate.inspectedX != inspectedX ||
        oldDelegate.inspectedY != inspectedY ||
        oldDelegate.isDark != isDark;
  }
}
