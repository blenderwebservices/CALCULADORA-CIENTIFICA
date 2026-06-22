import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../utils/calculator_state.dart';
import '../utils/matrix_ops.dart';

class MatrixScreen extends StatefulWidget {
  final CalculatorState state;

  const MatrixScreen({super.key, required this.state});

  @override
  _MatrixScreenState createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  late List<List<TextEditingController>> _controllersA;
  late List<List<TextEditingController>> _controllersB;
  late TextEditingController _controllerK;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores
    _controllersA = List.generate(
      2,
      (r) => List.generate(
        2,
        (c) => TextEditingController(text: _formatValue(widget.state.matrixA[r][c])),
      ),
    );
    _controllersB = List.generate(
      2,
      (r) => List.generate(
        2,
        (c) => TextEditingController(text: _formatValue(widget.state.matrixB[r][c])),
      ),
    );
    _controllerK = TextEditingController(text: _formatValue(widget.state.scalarK));

    // Escuchar cambios de estado para sincronizar valores
    widget.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    for (var row in _controllersA) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    for (var row in _controllersB) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    _controllerK.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {
      _syncControllers();
    });
  }

  String _formatValue(double v) {
    if (v == 0.0) return '';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toString();
  }

  void _syncControllers() {
    // Sincronizar Matrix A
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        final val = widget.state.matrixA[r][c];
        final ctrl = _controllersA[r][c];
        final double? ctrlVal = double.tryParse(ctrl.text);
        if (ctrlVal != val) {
          ctrl.text = _formatValue(val);
        }
      }
    }
    // Sincronizar Matrix B
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        final val = widget.state.matrixB[r][c];
        final ctrl = _controllersB[r][c];
        final double? ctrlVal = double.tryParse(ctrl.text);
        if (ctrlVal != val) {
          ctrl.text = _formatValue(val);
        }
      }
    }
    // Sincronizar Escalar K
    final valK = widget.state.scalarK;
    final double? ctrlKVal = double.tryParse(_controllerK.text);
    if (ctrlKVal != valK) {
      _controllerK.text = valK % 1 == 0 ? valK.toInt().toString() : valK.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado del panel de matrices
              _buildHeader(),
              const SizedBox(height: 16),
              // Matrices A y B lado a lado o apiladas
              _buildMatricesLayout(context),
              const SizedBox(height: 20),
              // Botones de Operaciones
              _buildOperationsPanel(context),
              const SizedBox(height: 20),
              // Matriz Resultado
              _buildResultPanel(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Calculadora de Matrices',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            // Botón de Swap A <-> B
            _buildIconButton(
              icon: Icons.swap_horiz,
              label: 'A ↔ B',
              onTap: () => widget.state.swapMatrices(),
            ),
            const SizedBox(width: 8),
            // Botón de Limpiar
            _buildIconButton(
              icon: Icons.delete_outline,
              label: 'Limpiar',
              textColor: Colors.redAccent,
              onTap: () => widget.state.clearMatrices(),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor ?? Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: textColor ?? Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatricesLayout(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 600;

    if (isNarrow) {
      return Column(
        children: [
          _buildMatrixBox('A'),
          const SizedBox(height: 16),
          _buildMatrixBox('B'),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildMatrixBox('A')),
        const SizedBox(width: 16),
        Expanded(child: _buildMatrixBox('B')),
      ],
    );
  }

  Widget _buildMatrixBox(String name) {
    final bool isA = name == 'A';
    final int rows = isA ? widget.state.matrixARows : widget.state.matrixBRows;
    final int cols = isA ? widget.state.matrixACols : widget.state.matrixBCols;

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matriz $name',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              // Selectores de dimensión
              Row(
                children: [
                  Text('F:', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                  const SizedBox(width: 4),
                  _buildDimSelector(
                    value: rows,
                    onChanged: (val) {
                      if (val != null) {
                        if (isA) {
                          widget.state.updateMatrixADimensions(val, widget.state.matrixACols);
                        } else {
                          widget.state.updateMatrixBDimensions(val, widget.state.matrixBCols);
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('C:', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                  const SizedBox(width: 4),
                  _buildDimSelector(
                    value: cols,
                    onChanged: (val) {
                      if (val != null) {
                        if (isA) {
                          widget.state.updateMatrixADimensions(widget.state.matrixARows, val);
                        } else {
                          widget.state.updateMatrixBDimensions(widget.state.matrixBRows, val);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cuadrícula de Inputs
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Corchete Izquierdo
                Text(
                  '[',
                  style: GoogleFonts.outfit(
                    fontSize: rows == 2 ? 80 : 44,
                    fontWeight: FontWeight.w200,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 6),
                // Celdas
                SizedBox(
                  width: 140,
                  child: Column(
                    children: List.generate(rows, (r) {
                      return Row(
                        children: List.generate(cols, (c) {
                          final ctrl = isA ? _controllersA[r][c] : _controllersB[r][c];
                          return Expanded(
                            child: Container(
                              height: 36,
                              margin: const EdgeInsets.all(4),
                              child: TextField(
                                controller: ctrl,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.03),
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0',
                                  hintStyle: GoogleFonts.outfit(color: Colors.white24),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (val) {
                                  final double parsed = double.tryParse(val) ?? 0.0;
                                  if (isA) {
                                    widget.state.setMatrixAValue(r, c, parsed);
                                  } else {
                                    widget.state.setMatrixBValue(r, c, parsed);
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                // Corchete Derecho
                Text(
                  ']',
                  style: GoogleFonts.outfit(
                    fontSize: rows == 2 ? 80 : 44,
                    fontWeight: FontWeight.w200,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDimSelector({required int value, required ValueChanged<int?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          dropdownColor: const Color(0xFF1E1B2E),
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          icon: const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white70),
          isDense: true,
          items: const [
            DropdownMenuItem(value: 1, child: Text('1')),
            DropdownMenuItem(value: 2, child: Text('2')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOperationsPanel(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Operaciones',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          // Fila 1: A+B, A-B, A*B
          Row(
            children: [
              _buildOpButton('A + B', () => widget.state.matrixAdd()),
              _buildOpButton('A − B', () => widget.state.matrixSubtract()),
              _buildOpButton('A × B', () => widget.state.matrixMultiply()),
            ],
          ),
          const SizedBox(height: 6),
          // Fila 2: det(A), A^-1, A^T
          Row(
            children: [
              _buildOpButton('det(A)', () => widget.state.matrixDeterminant('a'), isSecondary: true),
              _buildOpButton('A⁻¹', () => widget.state.matrixInverse('a'), isSecondary: true),
              _buildOpButton('Aᵀ', () => widget.state.matrixTranspose('a'), isSecondary: true),
            ],
          ),
          const SizedBox(height: 6),
          // Fila 3: det(B), B^-1, B^T
          Row(
            children: [
              _buildOpButton('det(B)', () => widget.state.matrixDeterminant('b'), isSecondary: true),
              _buildOpButton('B⁻¹', () => widget.state.matrixInverse('b'), isSecondary: true),
              _buildOpButton('Bᵀ', () => widget.state.matrixTranspose('b'), isSecondary: true),
            ],
          ),
          const SizedBox(height: 12),
          // Multiplicación Escalar
          _buildScalarRow(),
        ],
      ),
    );
  }

  Widget _buildOpButton(String label, VoidCallback onTap, {bool isSecondary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSecondary 
                ? Colors.deepPurple.withValues(alpha: 0.2) 
                : Colors.orange.withValues(alpha: 0.2),
            foregroundColor: isSecondary ? const Color(0xFFC084FC) : const Color(0xFFFB923C),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSecondary 
                    ? Colors.deepPurple.withValues(alpha: 0.3) 
                    : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScalarRow() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Text(
            'Escalar k:',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            height: 32,
            child: TextField(
              controller: _controllerK,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (val) {
                final double? parsed = double.tryParse(val);
                if (parsed != null) {
                  widget.state.updateScalarK(parsed);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          // Botón usar calculadora
          InkWell(
            onTap: () {
              widget.state.importKFromCalculator();
              _controllerK.text = widget.state.scalarK % 1 == 0 
                  ? widget.state.scalarK.toInt().toString() 
                  : widget.state.scalarK.toString();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Usar Calcu',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Spacer(),
          // Acciones k * A y k * B
          Row(
            children: [
              _buildScalarOpButton('k · A', () => widget.state.matrixScalarMultiply('a')),
              const SizedBox(width: 4),
              _buildScalarOpButton('k · B', () => widget.state.matrixScalarMultiply('b')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildScalarOpButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResultPanel() {
    final hasResult = widget.state.matrixResult != null || widget.state.scalarResult != null || widget.state.matrixError != null;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Resultado Matricial',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          // Caja de contenido del resultado
          _buildResultContent(),
          // Acciones de destino si hay un resultado válido (y no es error)
          if (hasResult && widget.state.matrixError == null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.state.matrixResult != null) ...[
                  _buildResultActionButton(
                    label: 'Copiar a A',
                    onTap: () => widget.state.copyResultToA(),
                  ),
                  const SizedBox(width: 8),
                  _buildResultActionButton(
                    label: 'Copiar a B',
                    onTap: () => widget.state.copyResultToB(),
                  ),
                  const SizedBox(width: 8),
                ],
                _buildResultActionButton(
                  label: 'Enviar a Calcu',
                  isAccent: true,
                  onTap: () => widget.state.sendResultToCalculator(),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    if (widget.state.matrixError != null) {
      return Center(
        child: Text(
          widget.state.matrixError!,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (widget.state.scalarResult != null) {
      return Center(
        child: Text(
          MatrixOps.formatDouble(widget.state.scalarResult!),
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC084FC),
          ),
        ),
      );
    }

    if (widget.state.matrixResult != null) {
      final res = widget.state.matrixResult!;
      final rCount = res.length;
      final cCount = res[0].length;

      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Corchete Izquierdo
            Text(
              '[',
              style: GoogleFonts.outfit(
                fontSize: rCount == 2 ? 80 : 44,
                fontWeight: FontWeight.w200,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 6),
            // Rejilla de Celdas
            SizedBox(
              width: 140,
              child: Column(
                children: List.generate(rCount, (r) {
                  return Row(
                    children: List.generate(cCount, (c) {
                      return Expanded(
                        child: Container(
                          height: 36,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Center(
                            child: Text(
                              MatrixOps.formatDouble(res[r][c]),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
            const SizedBox(width: 6),
            // Corchete Derecho
            Text(
              ']',
              style: GoogleFonts.outfit(
                fontSize: rCount == 2 ? 80 : 44,
                fontWeight: FontWeight.w200,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    // Placeholder por defecto
    return Center(
      child: Text(
        'Selecciona una operación de matriz para calcular el resultado.',
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: Colors.white38,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResultActionButton({
    required String label,
    bool isAccent = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAccent ? const Color(0xFF6366F1) : Colors.white.withValues(alpha: 0.06),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isAccent ? Colors.indigo.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
