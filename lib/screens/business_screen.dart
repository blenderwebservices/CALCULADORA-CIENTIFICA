import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';
import '../utils/calculator_state.dart';
import '../utils/matrix_ops.dart';

class BusinessScreen extends StatefulWidget {
  final CalculatorState state;

  const BusinessScreen({super.key, required this.state});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  int _activeModule = 0; // 0: Préstamo, 1: Interés, 2: Punto Eq, 3: Margen, 4: ROI, 5: IVA

  // 1. Préstamo
  final TextEditingController _loanAmountCtrl = TextEditingController(text: '100000');
  final TextEditingController _loanRateCtrl = TextEditingController(text: '12');
  final TextEditingController _loanTermCtrl = TextEditingController(text: '12');
  bool _loanTermInYears = false;
  Map<String, double>? _loanResult;

  // 2. Interés Compuesto / Simple
  final TextEditingController _interestPrincipalCtrl = TextEditingController(text: '10000');
  final TextEditingController _interestMonthlyCtrl = TextEditingController(text: '500');
  final TextEditingController _interestRateCtrl = TextEditingController(text: '8');
  final TextEditingController _interestYearsCtrl = TextEditingController(text: '5');
  bool _isCompound = true;
  final int _compoundFrequency = 12; // 12: mensual
  Map<String, double>? _interestResult;

  // 3. Punto de Equilibrio
  final TextEditingController _fixedCostsCtrl = TextEditingController(text: '50000');
  final TextEditingController _unitPriceCtrl = TextEditingController(text: '200');
  final TextEditingController _unitVarCostCtrl = TextEditingController(text: '100');
  Map<String, double>? _breakEvenResult;

  // 4. Margen & Markup
  final TextEditingController _costPriceCtrl = TextEditingController(text: '150');
  final TextEditingController _salePriceCtrl = TextEditingController(text: '220');
  Map<String, double>? _marginResult;

  // 5. ROI
  final TextEditingController _roiInvestedCtrl = TextEditingController(text: '25000');
  final TextEditingController _roiReturnedCtrl = TextEditingController(text: '35000');
  Map<String, double>? _roiResult;

  // 6. IVA / Impuestos
  final TextEditingController _vatAmountCtrl = TextEditingController(text: '1000');
  final TextEditingController _vatRateCtrl = TextEditingController(text: '16');
  bool _vatAddMode = true; // true: agregar IVA, false: desglosar IVA
  Map<String, double>? _vatResult;

  @override
  void initState() {
    super.initState();
    _calculateLoan();
    _calculateInterest();
    _calculateBreakEven();
    _calculateMargin();
    _calculateRoi();
    _calculateVat();
  }

  @override
  void dispose() {
    _loanAmountCtrl.dispose();
    _loanRateCtrl.dispose();
    _loanTermCtrl.dispose();
    _interestPrincipalCtrl.dispose();
    _interestMonthlyCtrl.dispose();
    _interestRateCtrl.dispose();
    _interestYearsCtrl.dispose();
    _fixedCostsCtrl.dispose();
    _unitPriceCtrl.dispose();
    _unitVarCostCtrl.dispose();
    _costPriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _roiInvestedCtrl.dispose();
    _roiReturnedCtrl.dispose();
    _vatAmountCtrl.dispose();
    _vatRateCtrl.dispose();
    super.dispose();
  }

  // --- CÁLCULOS ---

  void _calculateLoan() {
    final double p = double.tryParse(_loanAmountCtrl.text) ?? 0.0;
    final double r = (double.tryParse(_loanRateCtrl.text) ?? 0.0) / 100.0;
    final double termRaw = double.tryParse(_loanTermCtrl.text) ?? 0.0;
    final int months = _loanTermInYears ? (termRaw * 12).round() : termRaw.round();

    if (p <= 0 || months <= 0) {
      setState(() => _loanResult = null);
      return;
    }

    final double monthlyRate = r / 12.0;
    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = p / months;
    } else {
      monthlyPayment = p * (monthlyRate * math.pow(1 + monthlyRate, months)) / (math.pow(1 + monthlyRate, months) - 1);
    }
    final double totalPayment = monthlyPayment * months;
    final double totalInterest = totalPayment - p;

    setState(() {
      _loanResult = {
        'monthly': monthlyPayment,
        'total': totalPayment,
        'interest': totalInterest,
        'principal': p,
        'months': months.toDouble(),
      };
    });
  }

  void _calculateInterest() {
    final double p = double.tryParse(_interestPrincipalCtrl.text) ?? 0.0;
    final double pmt = double.tryParse(_interestMonthlyCtrl.text) ?? 0.0;
    final double r = (double.tryParse(_interestRateCtrl.text) ?? 0.0) / 100.0;
    final double years = double.tryParse(_interestYearsCtrl.text) ?? 0.0;

    if (years <= 0) {
      setState(() => _interestResult = null);
      return;
    }

    double finalAmount = 0.0;
    double totalDeposited = p;

    if (!_isCompound) {
      // Interés Simple
      final double totalInterest = (p * r * years) + (pmt * 12 * years * r * years / 2);
      totalDeposited = p + (pmt * 12 * years);
      finalAmount = totalDeposited + totalInterest;
    } else {
      // Interés Compuesto con aportes mensuales
      final int n = _compoundFrequency;
      final double rPeriod = r / n;
      final int totalPeriods = (years * n).round();

      // Crecimiento del principal
      double principalGrowth = p * math.pow(1 + rPeriod, totalPeriods);

      // Crecimiento de los aportes periódicos
      double contributionsGrowth = 0.0;
      if (pmt > 0) {
        final double rMonthly = r / 12.0;
        final int totalMonths = (years * 12).round();
        if (rMonthly > 0) {
          contributionsGrowth = pmt * ((math.pow(1 + rMonthly, totalMonths) - 1) / rMonthly);
        } else {
          contributionsGrowth = pmt * totalMonths;
        }
        totalDeposited = p + (pmt * totalMonths);
      } else {
        totalDeposited = p;
      }

      finalAmount = principalGrowth + contributionsGrowth;
    }

    final double totalInterest = finalAmount - totalDeposited;

    setState(() {
      _interestResult = {
        'final': finalAmount,
        'deposited': totalDeposited,
        'interest': totalInterest > 0 ? totalInterest : 0.0,
      };
    });
  }

  void _calculateBreakEven() {
    final double fixed = double.tryParse(_fixedCostsCtrl.text) ?? 0.0;
    final double price = double.tryParse(_unitPriceCtrl.text) ?? 0.0;
    final double varCost = double.tryParse(_unitVarCostCtrl.text) ?? 0.0;

    final double margin = price - varCost;
    if (margin <= 0 || fixed < 0) {
      setState(() => _breakEvenResult = null);
      return;
    }

    final double units = fixed / margin;
    final double sales = units * price;
    final double marginRatio = (margin / price) * 100.0;

    setState(() {
      _breakEvenResult = {
        'units': units,
        'sales': sales,
        'margin': margin,
        'marginRatio': marginRatio,
      };
    });
  }

  void _calculateMargin() {
    final double cost = double.tryParse(_costPriceCtrl.text) ?? 0.0;
    final double price = double.tryParse(_salePriceCtrl.text) ?? 0.0;

    if (price <= 0 || cost < 0) {
      setState(() => _marginResult = null);
      return;
    }

    final double profit = price - cost;
    final double margin = (profit / price) * 100.0;
    final double markup = cost > 0 ? (profit / cost) * 100.0 : 0.0;

    setState(() {
      _marginResult = {
        'profit': profit,
        'margin': margin,
        'markup': markup,
      };
    });
  }

  void _calculateRoi() {
    final double inv = double.tryParse(_roiInvestedCtrl.text) ?? 0.0;
    final double ret = double.tryParse(_roiReturnedCtrl.text) ?? 0.0;

    if (inv <= 0) {
      setState(() => _roiResult = null);
      return;
    }

    final double netProfit = ret - inv;
    final double roiPercent = (netProfit / inv) * 100.0;
    final double multiple = ret / inv;

    setState(() {
      _roiResult = {
        'profit': netProfit,
        'roi': roiPercent,
        'multiple': multiple,
      };
    });
  }

  void _calculateVat() {
    final double amount = double.tryParse(_vatAmountCtrl.text) ?? 0.0;
    final double rate = (double.tryParse(_vatRateCtrl.text) ?? 0.0) / 100.0;

    if (amount <= 0 || rate < 0) {
      setState(() => _vatResult = null);
      return;
    }

    double subtotal;
    double vatAmount;
    double total;

    if (_vatAddMode) {
      // Agregar IVA (Neto -> Total)
      subtotal = amount;
      vatAmount = amount * rate;
      total = subtotal + vatAmount;
    } else {
      // Desglosar IVA (Total -> Neto)
      total = amount;
      subtotal = total / (1.0 + rate);
      vatAmount = total - subtotal;
    }

    setState(() {
      _vatResult = {
        'subtotal': subtotal,
        'vat': vatAmount,
        'total': total,
      };
    });
  }

  // --- REGISTRO EN HISTORIAL ---
  void _saveToHistory(String title, String expression, String result, double? numeric) {
    widget.state.addBusinessHistoryItem(
      title: title,
      expression: expression,
      result: result,
      numericResult: numeric,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title guardado en el historial'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
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
                'Calculadora de Negocios',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'FINANCIERA',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Selector de Módulos (Scroll horizontal de Chips)
          _buildModuleSelector(isDark),
          const SizedBox(height: 16),

          // Contenido del Módulo Activo
          _buildActiveModuleCard(isDark, primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildModuleSelector(bool isDark) {
    final modules = [
      {'title': 'Préstamos', 'icon': Icons.account_balance_outlined},
      {'title': 'Interés Compuesto', 'icon': Icons.trending_up},
      {'title': 'Punto de Equilibrio', 'icon': Icons.balance_outlined},
      {'title': 'Margen & Markup', 'icon': Icons.point_of_sale_outlined},
      {'title': 'ROI', 'icon': Icons.pie_chart_outline},
      {'title': 'Impuestos / IVA', 'icon': Icons.receipt_long_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(modules.length, (idx) {
          final isSelected = _activeModule == idx;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _activeModule = idx),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1).withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      modules[idx]['icon'] as IconData,
                      size: 15,
                      color: isSelected
                          ? const Color(0xFFC084FC)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      modules[idx]['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFC084FC)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveModuleCard(bool isDark, Color primaryText, Color secondaryText) {
    switch (_activeModule) {
      case 0:
        return _buildLoanCard(isDark, primaryText, secondaryText);
      case 1:
        return _buildInterestCard(isDark, primaryText, secondaryText);
      case 2:
        return _buildBreakEvenCard(isDark, primaryText, secondaryText);
      case 3:
        return _buildMarginCard(isDark, primaryText, secondaryText);
      case 4:
        return _buildRoiCard(isDark, primaryText, secondaryText);
      case 5:
        return _buildVatCard(isDark, primaryText, secondaryText);
      default:
        return const SizedBox.shrink();
    }
  }

  // =====================================================================
  // 1. MÓDULO PRÉSTAMOS
  // =====================================================================
  Widget _buildLoanCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amortización y Cuota Mensual',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
              _buildSaveButton(() {
                if (_loanResult != null) {
                  _saveToHistory(
                    'Préstamo',
                    '\$${_loanAmountCtrl.text} al ${_loanRateCtrl.text}% anual por ${_loanTermCtrl.text} ${_loanTermInYears ? "años" : "meses"}',
                    'Cuota: \$${MatrixOps.formatDouble(_loanResult!["monthly"]!)} | Total: \$${MatrixOps.formatDouble(_loanResult!["total"]!)}',
                    _loanResult!['monthly'],
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 14),

          _buildInputField('Monto del Préstamo (\$)', _loanAmountCtrl, isDark, primaryText, _calculateLoan),
          const SizedBox(height: 10),
          _buildInputField('Tasa de Interés Anual Nominal (%)', _loanRateCtrl, isDark, primaryText, _calculateLoan),
          const SizedBox(height: 10),

          // Plazo con selector Meses / Años
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  _loanTermInYears ? 'Plazo (Años)' : 'Plazo (Meses)',
                  _loanTermCtrl,
                  isDark,
                  primaryText,
                  _calculateLoan,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _loanTermInYears = !_loanTermInYears;
                      _calculateLoan();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    side: BorderSide(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _loanTermInYears ? 'Años' : 'Meses',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFC084FC)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Resultados
          if (_loanResult != null) ...[
            _buildResultCard(
              title: 'Cuota Mensual Estimada',
              value: '\$${MatrixOps.formatDouble(_loanResult!['monthly']!)}',
              accentColor: const Color(0xFFC084FC),
              details: [
                {'label': 'Total a pagar:', 'val': '\$${MatrixOps.formatDouble(_loanResult!['total']!)}'},
                {'label': 'Intereses totales:', 'val': '\$${MatrixOps.formatDouble(_loanResult!['interest']!)}'},
                {'label': 'Monto financiado:', 'val': '\$${MatrixOps.formatDouble(_loanResult!['principal']!)}'},
                {'label': 'Plazo en meses:', 'val': '${_loanResult!['months']!.toInt()} cuotas'},
              ],
            ),
          ] else
            _buildEmptyCalcMessage('Ingresa valores válidos para calcular la amortización.'),
        ],
      ),
    );
  }

  // =====================================================================
  // 2. MÓDULO INTERÉS COMPUESTO & SIMPLE
  // =====================================================================
  Widget _buildInterestCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interés Compuesto y Simple',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
              _buildSaveButton(() {
                if (_interestResult != null) {
                  _saveToHistory(
                    _isCompound ? 'Interés Compuesto' : 'Interés Simple',
                    'Cap: \$${_interestPrincipalCtrl.text}, ${_interestRateCtrl.text}% en ${_interestYearsCtrl.text} años',
                    'Final: \$${MatrixOps.formatDouble(_interestResult!["final"]!)} (Rendimiento: \$${MatrixOps.formatDouble(_interestResult!["interest"]!)})',
                    _interestResult!['final'],
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Conmutador Compuesto / Simple
          Row(
            children: [
              _buildTabPill('Compuesto', _isCompound, () {
                setState(() {
                  _isCompound = true;
                  _calculateInterest();
                });
              }, isDark),
              const SizedBox(width: 8),
              _buildTabPill('Simple', !_isCompound, () {
                setState(() {
                  _isCompound = false;
                  _calculateInterest();
                });
              }, isDark),
            ],
          ),
          const SizedBox(height: 12),

          _buildInputField('Capital Inicial (\$)', _interestPrincipalCtrl, isDark, primaryText, _calculateInterest),
          const SizedBox(height: 10),
          _buildInputField('Aporte Periódico Mensual (\$)', _interestMonthlyCtrl, isDark, primaryText, _calculateInterest),
          const SizedBox(height: 10),
          _buildInputField('Tasa Anual Estimada (%)', _interestRateCtrl, isDark, primaryText, _calculateInterest),
          const SizedBox(height: 10),
          _buildInputField('Tiempo en Años', _interestYearsCtrl, isDark, primaryText, _calculateInterest),
          const SizedBox(height: 18),

          if (_interestResult != null) ...[
            _buildResultCard(
              title: 'Monto Final Acumulado',
              value: '\$${MatrixOps.formatDouble(_interestResult!['final']!)}',
              accentColor: const Color(0xFF10B981),
              details: [
                {'label': 'Total Capital Invertido:', 'val': '\$${MatrixOps.formatDouble(_interestResult!['deposited']!)}'},
                {'label': 'Ganancia en Intereses:', 'val': '\$${MatrixOps.formatDouble(_interestResult!['interest']!)}'},
                {
                  'label': 'Rendimiento sobre inversión:',
                  'val': _interestResult!['deposited']! > 0
                      ? '${MatrixOps.formatDouble((_interestResult!['interest']! / _interestResult!['deposited']!) * 100)}%'
                      : '0%'
                },
              ],
            ),
          ] else
            _buildEmptyCalcMessage('Completa los campos para estimar el rendimiento.'),
        ],
      ),
    );
  }

  // =====================================================================
  // 3. MÓDULO PUNTO DE EQUILIBRIO
  // =====================================================================
  Widget _buildBreakEvenCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Punto de Equilibrio (Break-Even)',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
              _buildSaveButton(() {
                if (_breakEvenResult != null) {
                  _saveToHistory(
                    'Punto de Equilibrio',
                    'CF: \$${_fixedCostsCtrl.text}, PV: \$${_unitPriceCtrl.text}, CV: \$${_unitVarCostCtrl.text}',
                    'Unidades: ${MatrixOps.formatDouble(_breakEvenResult!["units"]!)} (Ventas mínimas: \$${MatrixOps.formatDouble(_breakEvenResult!["sales"]!)})',
                    _breakEvenResult!['units'],
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 14),

          _buildInputField('Costos Fijos Totales (\$)', _fixedCostsCtrl, isDark, primaryText, _calculateBreakEven),
          const SizedBox(height: 10),
          _buildInputField('Precio de Venta por Unidad (\$)', _unitPriceCtrl, isDark, primaryText, _calculateBreakEven),
          const SizedBox(height: 10),
          _buildInputField('Costo Variable por Unidad (\$)', _unitVarCostCtrl, isDark, primaryText, _calculateBreakEven),
          const SizedBox(height: 18),

          if (_breakEvenResult != null) ...[
            _buildResultCard(
              title: 'Unidades Mínimas de Venta',
              value: '${MatrixOps.formatDouble(_breakEvenResult!['units']!)} uds.',
              accentColor: const Color(0xFFF59E0B),
              details: [
                {'label': 'Ingresos necesarios para equilibrio:', 'val': '\$${MatrixOps.formatDouble(_breakEvenResult!['sales']!)}'},
                {'label': 'Margen de contribución unitario:', 'val': '\$${MatrixOps.formatDouble(_breakEvenResult!['margin']!)}'},
                {'label': 'Ratio de contribución marginal:', 'val': '${MatrixOps.formatDouble(_breakEvenResult!['marginRatio']!)}%'},
              ],
            ),
          ] else
            _buildEmptyCalcMessage('El precio unitario debe ser mayor que el costo variable unitario.'),
        ],
      ),
    );
  }

  // =====================================================================
  // 4. MÓDULO MARGEN & MARKUP
  // =====================================================================
  Widget _buildMarginCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Margen de Ganancia y Markup',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
              _buildSaveButton(() {
                if (_marginResult != null) {
                  _saveToHistory(
                    'Margen y Markup',
                    'Costo: \$${_costPriceCtrl.text}, Venta: \$${_salePriceCtrl.text}',
                    'Margen: ${MatrixOps.formatDouble(_marginResult!["margin"]!)}% | Markup: ${MatrixOps.formatDouble(_marginResult!["markup"]!)}% (Ganancia: \$${MatrixOps.formatDouble(_marginResult!["profit"]!)})',
                    _marginResult!['margin'],
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 14),

          _buildInputField('Costo del Producto (\$)', _costPriceCtrl, isDark, primaryText, _calculateMargin),
          const SizedBox(height: 10),
          _buildInputField('Precio de Venta al Público (\$)', _salePriceCtrl, isDark, primaryText, _calculateMargin),
          const SizedBox(height: 18),

          if (_marginResult != null) ...[
            _buildResultCard(
              title: 'Margen de Ganancia Bruto',
              value: '${MatrixOps.formatDouble(_marginResult!['margin']!)}%',
              accentColor: const Color(0xFF6366F1),
              details: [
                {'label': 'Markup (Margen sobre costo):', 'val': '${MatrixOps.formatDouble(_marginResult!['markup']!)}%'},
                {'label': 'Ganancia en dinero:', 'val': '\$${MatrixOps.formatDouble(_marginResult!['profit']!)}'},
                {
                  'label': 'Relación Costo/Venta:',
                  'val': '${MatrixOps.formatDouble(100.0 - _marginResult!['margin']!)}%'
                },
              ],
            ),
          ] else
            _buildEmptyCalcMessage('El precio de venta debe ser superior a 0.'),
        ],
      ),
    );
  }

  // =====================================================================
  // 5. MÓDULO RETORNO DE INVERSIÓN (ROI)
  // =====================================================================
  Widget _buildRoiCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Retorno de Inversión (ROI)',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
              _buildSaveButton(() {
                if (_roiResult != null) {
                  _saveToHistory(
                    'ROI',
                    'Invertido: \$${_roiInvestedCtrl.text}, Retorno: \$${_roiReturnedCtrl.text}',
                    'ROI: ${MatrixOps.formatDouble(_roiResult!["roi"]!)}% (Ganancia neta: \$${MatrixOps.formatDouble(_roiResult!["profit"]!)})',
                    _roiResult!['roi'],
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 14),

          _buildInputField('Monto Total Invertido (\$)', _roiInvestedCtrl, isDark, primaryText, _calculateRoi),
          const SizedBox(height: 10),
          _buildInputField('Retorno o Ingreso Total Obtenido (\$)', _roiReturnedCtrl, isDark, primaryText, _calculateRoi),
          const SizedBox(height: 18),

          if (_roiResult != null) ...[
            _buildResultCard(
              title: 'Retorno de Inversión (ROI)',
              value: '${MatrixOps.formatDouble(_roiResult!['roi']!)}%',
              accentColor: _roiResult!['roi']! >= 0 ? const Color(0xFF10B981) : Colors.redAccent,
              details: [
                {'label': 'Ganancia Neta Obtenida:', 'val': '\$${MatrixOps.formatDouble(_roiResult!['profit']!)}'},
                {'label': 'Multiplicador de inversión:', 'val': '${MatrixOps.formatDouble(_roiResult!['multiple']!)}x'},
                {
                  'label': 'Estado:',
                  'val': _roiResult!['profit']! >= 0 ? 'Inversión Rentable' : 'Pérdida Neta'
                },
              ],
            ),
          ] else
            _buildEmptyCalcMessage('Ingresa una inversión superior a 0.'),
        ],
      ),
    );
  }

  // =====================================================================
  // 6. MÓDULO IMPUESTOS / IVA
  // =====================================================================
  Widget _buildVatCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cálculo y Desglose de IVA',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
              _buildSaveButton(() {
                if (_vatResult != null) {
                  _saveToHistory(
                    _vatAddMode ? 'Agregar IVA' : 'Desglosar IVA',
                    'Base: \$${_vatAmountCtrl.text} al ${_vatRateCtrl.text}%',
                    'IVA: \$${MatrixOps.formatDouble(_vatResult!["vat"]!)} | Total: \$${MatrixOps.formatDouble(_vatResult!["total"]!)}',
                    _vatResult!['total'],
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Modo: Agregar IVA vs Desglosar IVA
          Row(
            children: [
              _buildTabPill('Agregar IVA (Neto → Bruto)', _vatAddMode, () {
                setState(() {
                  _vatAddMode = true;
                  _calculateVat();
                });
              }, isDark),
              const SizedBox(width: 8),
              _buildTabPill('Desglosar IVA (Bruto → Neto)', !_vatAddMode, () {
                setState(() {
                  _vatAddMode = false;
                  _calculateVat();
                });
              }, isDark),
            ],
          ),
          const SizedBox(height: 12),

          _buildInputField(
            _vatAddMode ? 'Importe Base sin IVA (\$)' : 'Importe Total con IVA (\$)',
            _vatAmountCtrl,
            isDark,
            primaryText,
            _calculateVat,
          ),
          const SizedBox(height: 10),

          // Tasa de IVA con Presets Rápidos (16%, 21%, 10%, 8%)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInputField('Tasa de IVA (%)', _vatRateCtrl, isDark, primaryText, _calculateVat),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: ['16', '21', '10', '8', '0'].map((rate) {
                  return InkWell(
                    onTap: () {
                      _vatRateCtrl.text = rate;
                      _calculateVat();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _vatRateCtrl.text == rate
                            ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _vatRateCtrl.text == rate
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '$rate%',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _vatRateCtrl.text == rate ? const Color(0xFFC084FC) : secondaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (_vatResult != null) ...[
            _buildResultCard(
              title: _vatAddMode ? 'Total Final con IVA' : 'Subtotal sin IVA',
              value: '\$${MatrixOps.formatDouble(_vatAddMode ? _vatResult!['total']! : _vatResult!['subtotal']!)}',
              accentColor: const Color(0xFF38BDF8),
              details: [
                {'label': 'Subtotal (Neto):', 'val': '\$${MatrixOps.formatDouble(_vatResult!['subtotal']!)}'},
                {'label': 'Impuesto IVA (${_vatRateCtrl.text}%):', 'val': '\$${MatrixOps.formatDouble(_vatResult!['vat']!)}'},
                {'label': 'Total Facturado:', 'val': '\$${MatrixOps.formatDouble(_vatResult!['total']!)}'},
              ],
            ),
          ] else
            _buildEmptyCalcMessage('Introduce un importe válido.'),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    bool isDark,
    Color primaryText,
    VoidCallback onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(fontSize: 14, color: primaryText, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: InputBorder.none,
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required Color accentColor,
    required List<Map<String, String>> details,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F0C1B);
    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor),
          ),
          const SizedBox(height: 12),
          Divider(color: accentColor.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 8),
          ...details.map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d['label']!, style: GoogleFonts.outfit(fontSize: 12, color: secondaryText)),
                  Text(d['val']!, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: primaryText)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabPill(String title, bool isSelected, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFFC084FC) : (isDark ? Colors.white60 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(VoidCallback onSave) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onSave,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_add_outlined, size: 14, color: Color(0xFFC084FC)),
            const SizedBox(width: 4),
            Text(
              'Guardar',
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFC084FC)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCalcMessage(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
