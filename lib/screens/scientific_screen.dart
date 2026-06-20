import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../widgets/calc_button.dart';
import '../utils/calculator_state.dart';

class ScientificScreen extends StatelessWidget {
  final CalculatorState state;

  const ScientificScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Column(
          children: [
            // Pantalla (Visor de expresión y resultado)
            _buildScreen(context),
            const SizedBox(height: 12),
            // Fila de controles rápidos (DEG/RAD y Memoria)
            _buildUtilityRow(context),
            const SizedBox(height: 12),
            // Teclado
            Expanded(
              child: _buildKeypad(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScreen(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expresión superior
          Container(
            height: 32,
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                state.expressionText,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Visor de entrada inferior
          Container(
            height: 52,
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.inputText,
                    style: GoogleFonts.outfit(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!state.shouldResetScreen)
                    _BlinkingCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityRow(BuildContext context) {
    return Row(
      children: [
        // Botón DEG / RAD
        InkWell(
          onTap: () => state.toggleAngleMode(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text(
              state.angleMode,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC084FC), // light purple
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Indicador de memoria activa
        if (state.memoryValue != 0.0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'M',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        const Spacer(),
        // Controles de memoria MC, MR, M+, M-, MS
        _buildMemoryButton('MC', () => state.memoryClear(), 'Memory Clear'),
        _buildMemoryButton('MR', () => state.memoryRecall(), 'Memory Recall'),
        _buildMemoryButton('M+', () => state.memoryAdd(), 'Memory Add'),
        _buildMemoryButton('M-', () => state.memorySubtract(), 'Memory Subtract'),
        _buildMemoryButton('MS', () => state.memoryStore(), 'Memory Store'),
      ],
    );
  }

  Widget _buildMemoryButton(String label, VoidCallback onTap, String tooltip) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return Column(
      children: [
        // Fila 1: sin, cos, tan, (, )
        Expanded(
          child: Row(
            children: [
              CalcButton(text: 'sin', type: ButtonType.scientific, onTap: () => state.handleActionInput('sin')),
              CalcButton(text: 'cos', type: ButtonType.scientific, onTap: () => state.handleActionInput('cos')),
              CalcButton(text: 'tan', type: ButtonType.scientific, onTap: () => state.handleActionInput('tan')),
              CalcButton(text: '(', type: ButtonType.scientific, onTap: () => state.handleValInput('(')),
              CalcButton(text: ')', type: ButtonType.scientific, onTap: () => state.handleValInput(')')),
            ],
          ),
        ),
        // Fila 2: sin⁻¹, cos⁻¹, tan⁻¹, xʸ, √
        Expanded(
          child: Row(
            children: [
              CalcButton(text: 'sin⁻¹', type: ButtonType.scientific, onTap: () => state.handleActionInput('asin')),
              CalcButton(text: 'cos⁻¹', type: ButtonType.scientific, onTap: () => state.handleActionInput('acos')),
              CalcButton(text: 'tan⁻¹', type: ButtonType.scientific, onTap: () => state.handleActionInput('atan')),
              CalcButton(text: 'xʸ', type: ButtonType.scientific, onTap: () => state.handleValInput('^')),
              CalcButton(text: '√', type: ButtonType.scientific, onTap: () => state.handleActionInput('sqrt')),
            ],
          ),
        ),
        // Fila 3: ln, log, e, π, x!
        Expanded(
          child: Row(
            children: [
              CalcButton(text: 'ln', type: ButtonType.scientific, onTap: () => state.handleActionInput('ln')),
              CalcButton(text: 'log', type: ButtonType.scientific, onTap: () => state.handleActionInput('log')),
              CalcButton(text: 'e', type: ButtonType.scientific, onTap: () => state.handleValInput('e')),
              CalcButton(text: 'π', type: ButtonType.scientific, onTap: () => state.handleValInput('pi')),
              CalcButton(text: 'x!', type: ButtonType.scientific, onTap: () => state.handleActionInput('fact')),
            ],
          ),
        ),
        // Fila 4: AC, Backspace, %, ÷, ×
        Expanded(
          child: Row(
            children: [
              CalcButton(text: 'AC', type: ButtonType.action, onTap: () => state.handleClearAll()),
              CalcButton(
                child: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 20),
                type: ButtonType.action,
                onTap: () => state.handleBackspace(),
              ),
              CalcButton(text: '%', type: ButtonType.action, onTap: () => state.handleValInput('%')),
              CalcButton(text: '÷', type: ButtonType.operator, onTap: () => state.handleValInput('/')),
              CalcButton(text: '×', type: ButtonType.operator, onTap: () => state.handleValInput('*')),
            ],
          ),
        ),
        // Fila 5: 7, 8, 9, −, x²
        Expanded(
          child: Row(
            children: [
              CalcButton(text: '7', onTap: () => state.handleValInput('7')),
              CalcButton(text: '8', onTap: () => state.handleValInput('8')),
              CalcButton(text: '9', onTap: () => state.handleValInput('9')),
              CalcButton(text: '−', type: ButtonType.operator, onTap: () => state.handleValInput('-')),
              CalcButton(text: 'x²', type: ButtonType.scientific, onTap: () => state.handleActionInput('sqr')),
            ],
          ),
        ),
        // Fila 6: 4, 5, 6, +, x³
        Expanded(
          child: Row(
            children: [
              CalcButton(text: '4', onTap: () => state.handleValInput('4')),
              CalcButton(text: '5', onTap: () => state.handleValInput('5')),
              CalcButton(text: '6', onTap: () => state.handleValInput('6')),
              CalcButton(text: '+', type: ButtonType.operator, onTap: () => state.handleValInput('+')),
              CalcButton(text: 'x³', type: ButtonType.scientific, onTap: () => state.handleActionInput('cube')),
            ],
          ),
        ),
        // Fila 7: 1, 2, 3, recip (1/x), =
        Expanded(
          child: Row(
            children: [
              CalcButton(text: '1', onTap: () => state.handleValInput('1')),
              CalcButton(text: '2', onTap: () => state.handleValInput('2')),
              CalcButton(text: '3', onTap: () => state.handleValInput('3')),
              CalcButton(text: '1/x', type: ButtonType.scientific, onTap: () => state.handleActionInput('recip')),
              CalcButton(text: '=', type: ButtonType.equals, onTap: () => state.evaluateScientific()),
            ],
          ),
        ),
        // Fila 8: ±, 0, .
        // Para balancear, haremos que el 0 ocupe más espacio
        Expanded(
          child: Row(
            children: [
              CalcButton(text: '±', onTap: () => state.handleToggleSign()),
              CalcButton(text: '0', flex: 3, onTap: () => state.handleValInput('0')),
              CalcButton(text: '.', onTap: () => state.handleDecimalPoint()),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  __BlinkingCursorState createState() => __BlinkingCursorState();
}

class __BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value > 0.5 ? 1.0 : 0.0,
          child: Container(
            width: 3,
            height: 38,
            color: const Color(0xFF6366F1), // Indigo cursor
          ),
        );
      },
    );
  }
}
