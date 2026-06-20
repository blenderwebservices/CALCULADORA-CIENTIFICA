import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonType {
  number,
  scientific,
  operator,
  action,
  equals,
}

class CalcButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback onTap;
  final ButtonType type;
  final int flex;
  final String? tooltip;

  const CalcButton({
    Key? key,
    this.text,
    this.child,
    required this.onTap,
    this.type = ButtonType.number,
    this.flex = 1,
    this.tooltip,
  }) : super(key: key);

  @override
  _CalcButtonState createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (widget.type) {
      case ButtonType.number:
        return _isHovered 
            ? Colors.white.withOpacity(0.12) 
            : Colors.white.withOpacity(0.05);
      case ButtonType.scientific:
        return _isHovered 
            ? Colors.deepPurple.withOpacity(0.25) 
            : Colors.deepPurple.withOpacity(0.12);
      case ButtonType.operator:
        return _isHovered 
            ? Colors.orange.withOpacity(0.4) 
            : Colors.orange.withOpacity(0.25);
      case ButtonType.action:
        return _isHovered 
            ? Colors.redAccent.withOpacity(0.25) 
            : Colors.white.withOpacity(0.08);
      case ButtonType.equals:
        return const Color(0xFF6366F1); // Indigo accent color
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case ButtonType.number:
        return Colors.white;
      case ButtonType.scientific:
        return const Color(0xFFC084FC); // Purple text
      case ButtonType.operator:
        return const Color(0xFFFB923C); // Orange text
      case ButtonType.action:
        return widget.text == 'AC' ? const Color(0xFFF87171) : Colors.white70;
      case ButtonType.equals:
        return Colors.white;
    }
  }

  double _getFontSize() {
    switch (widget.type) {
      case ButtonType.number:
        return 20.0;
      case ButtonType.scientific:
        return 14.0;
      case ButtonType.operator:
        return 22.0;
      case ButtonType.action:
        return 16.0;
      case ButtonType.equals:
        return 22.0;
    }
  }

  FontWeight _getFontWeight() {
    switch (widget.type) {
      case ButtonType.number:
        return FontWeight.w500;
      case ButtonType.scientific:
        return FontWeight.w400;
      case ButtonType.operator:
        return FontWeight.bold;
      case ButtonType.action:
        return FontWeight.w600;
      case ButtonType.equals:
        return FontWeight.bold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _getBackgroundColor(context);
    final Color textColor = _getTextColor();
    final double fontSize = _getFontSize();
    final FontWeight fontWeight = _getFontWeight();

    Widget buttonBody = InkWell(
      onTap: () {}, // Handled by gesture detector for custom scale animation
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: widget.child ?? Text(
          widget.text ?? '',
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      buttonBody = Tooltip(
        message: widget.tooltip!,
        preferBelow: false,
        child: buttonBody,
      );
    }

    return Expanded(
      flex: widget.flex,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.type == ButtonType.equals
                      ? const Color(0xFF818CF8).withOpacity(0.5)
                      : Colors.white.withOpacity(0.06),
                  width: 1.0,
                ),
                boxShadow: widget.type == ButtonType.equals
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: buttonBody,
            ),
          ),
        ),
      ),
    );
  }
}
