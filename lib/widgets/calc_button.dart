import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_config.dart';
import '../utils/theme_manager.dart';

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
    super.key,
    this.text,
    this.child,
    required this.onTap,
    this.type = ButtonType.number,
    this.flex = 1,
    this.tooltip,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
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
    final theme = ThemeManager().currentTheme;
    Color base;
    switch (widget.type) {
      case ButtonType.number:
        base = theme.numButtonBg;
        break;
      case ButtonType.scientific:
        base = theme.sciButtonBg;
        break;
      case ButtonType.operator:
        base = theme.opButtonBg;
        break;
      case ButtonType.action:
        if (widget.text == 'AC') {
          base = theme.acButtonBg;
        } else if (widget.text == 'DEL') {
          base = theme.delButtonBg;
        } else {
          base = theme.sciButtonBg;
        }
        break;
      case ButtonType.equals:
        base = theme.equalsButtonBg;
        break;
    }

    if (_isHovered) {
      return Color.alphaBlend(Colors.white.withValues(alpha: theme.isDark ? 0.15 : 0.08), base);
    }
    return base;
  }

  Color _getTextColor() {
    final theme = ThemeManager().currentTheme;
    switch (widget.type) {
      case ButtonType.number:
        return theme.numButtonText;
      case ButtonType.scientific:
        return theme.sciButtonText;
      case ButtonType.operator:
        return theme.opButtonText;
      case ButtonType.action:
        if (widget.text == 'AC') {
          return theme.acButtonText;
        } else if (widget.text == 'DEL') {
          return theme.delButtonText;
        }
        return theme.sciButtonText;
      case ButtonType.equals:
        return theme.equalsButtonText;
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
    final theme = ThemeManager().currentTheme;
    final Color bgColor = _getBackgroundColor(context);
    final Color textColor = _getTextColor();
    final double fontSize = _getFontSize();
    final FontWeight fontWeight = _getFontWeight();

    Widget buttonBody = InkWell(
      onTap: () {
        _controller.reverse();
        if (AppConfig.clickSoundEnabled) {
          SystemSound.play(SystemSoundType.click);
        }
        widget.onTap();
      },
      onTapDown: (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.type == ButtonType.equals
                    ? theme.equalsButtonBg.withValues(alpha: 0.6)
                    : theme.cardBorderColor,
                width: 1.0,
              ),
              boxShadow: widget.type == ButtonType.equals
                  ? [
                      BoxShadow(
                        color: theme.equalsButtonBg.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : (theme.isAuthenticLcd
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: theme.isDark ? 0.25 : 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1.5),
                          ),
                        ]
                      : []),
            ),
            child: buttonBody,
          ),
        ),
      ),
    );
  }
}

