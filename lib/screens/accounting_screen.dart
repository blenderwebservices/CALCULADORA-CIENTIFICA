import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/accounting_ops.dart';
import '../utils/app_config.dart';
import '../utils/calculator_state.dart';
import '../widgets/glass_container.dart';

/// Elemento individual en la cinta de papel de la sumadora
class TapeEntry {
  final String id;
  final String operation; // '+', '-', '×', '÷', 'ST', 'TOTAL', 'TAX+', 'TAX-', 'MU'
  final double amount;
  final double subtotalAfter;
  String note;
  final DateTime timestamp;

  TapeEntry({
    required this.id,
    required this.operation,
    required this.amount,
    required this.subtotalAfter,
    this.note = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AccountingScreen extends StatefulWidget {
  final CalculatorState state;

  const AccountingScreen({super.key, required this.state});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  int _activeModule = 0; // 0: Sumadora, 1: Depreciación, 2: Ratios, 3: Nómina

  // =========================================================================
  // ESTADO DE LA SUMADORA CONTABLE
  // =========================================================================
  final List<TapeEntry> _tape = [];
  final ScrollController _tapeScrollController = ScrollController();
  String _inputBuffer = '';
  double _accumulator = 0.0;
  double _grandTotal = 0.0;
  double _memoryValue = 0.0;
  double _taxRate = 16.0; // % IVA / Impuesto por defecto

  // Controles de modo contable
  int _decimalPlaces = 2; // 0, 2, 3, 4 o -1 (F: Flotante)
  bool _addMode = false; // Modo ADD2 (ej: teclear 1250 se vuelve 12.50)
  AccountingRoundingMode _roundingMode = AccountingRoundingMode.round54;

  // =========================================================================
  // ESTADO DE DEPRECIACIÓN
  // =========================================================================
  final TextEditingController _depCostCtrl = TextEditingController(text: '120000');
  final TextEditingController _depSalvageCtrl = TextEditingController(text: '15000');
  final TextEditingController _depLifeCtrl = TextEditingController(text: '5');
  int _depMethod = 0; // 0: Línea Recta, 1: Suma de Dígitos (SYD), 2: Saldo Decreciente (DDB)
  List<DepreciationYearEntry> _depreciationSchedule = [];

  // =========================================================================
  // ESTADO DE RATIOS CONTABLES
  // =========================================================================
  int _ratiosSubCategory = 0; // 0: Liquidez, 1: Endeudamiento, 2: Rentabilidad
  // Liquidez
  final TextEditingController _curAssetsCtrl = TextEditingController(text: '150000');
  final TextEditingController _curLiabCtrl = TextEditingController(text: '80000');
  final TextEditingController _inventoryCtrl = TextEditingController(text: '35000');
  // Endeudamiento
  final TextEditingController _totLiabCtrl = TextEditingController(text: '220000');
  final TextEditingController _totAssetsCtrl = TextEditingController(text: '450000');
  final TextEditingController _equityCtrl = TextEditingController(text: '230000');
  // Rentabilidad
  final TextEditingController _netIncomeCtrl = TextEditingController(text: '65000');

  // =========================================================================
  // ESTADO DE NÓMINA Y RETENCIONES
  // =========================================================================
  final TextEditingController _payrollBaseCtrl = TextEditingController(text: '25000');
  final TextEditingController _payrollBonusCtrl = TextEditingController(text: '3000');
  final TextEditingController _payrollTaxRateCtrl = TextEditingController(text: '12.0');
  final TextEditingController _payrollEmployeeSSCtrl = TextEditingController(text: '5.1');
  final TextEditingController _payrollEmployerSSCtrl = TextEditingController(text: '18.5');
  final TextEditingController _payrollOtherDedCtrl = TextEditingController(text: '500');
  Map<String, double>? _payrollResult;

  @override
  void initState() {
    super.initState();
    _recalculateDepreciation();
    _recalculatePayroll();
  }

  @override
  void dispose() {
    _tapeScrollController.dispose();
    _depCostCtrl.dispose();
    _depSalvageCtrl.dispose();
    _depLifeCtrl.dispose();
    _curAssetsCtrl.dispose();
    _curLiabCtrl.dispose();
    _inventoryCtrl.dispose();
    _totLiabCtrl.dispose();
    _totAssetsCtrl.dispose();
    _equityCtrl.dispose();
    _netIncomeCtrl.dispose();
    _payrollBaseCtrl.dispose();
    _payrollBonusCtrl.dispose();
    _payrollTaxRateCtrl.dispose();
    _payrollEmployeeSSCtrl.dispose();
    _payrollEmployerSSCtrl.dispose();
    _payrollOtherDedCtrl.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    if (AppConfig.clickSoundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  // =========================================================================
  // LÓGICA DE LA SUMADORA CONTABLE
  // =========================================================================

  double _parseCurrentInput() {
    if (_inputBuffer.isEmpty) return 0.0;
    if (_addMode) {
      // Modo ADD2: 1250 -> 12.50
      final raw = double.tryParse(_inputBuffer) ?? 0.0;
      return raw / 100.0;
    }
    return double.tryParse(_inputBuffer) ?? 0.0;
  }

  void _scrollTapeToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tapeScrollController.hasClients) {
        _tapeScrollController.animateTo(
          _tapeScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onNumberKey(String digit) {
    _triggerHaptic();
    setState(() {
      if (digit == '.' && _inputBuffer.contains('.')) return;
      if (_addMode && digit == '.') return; // En ADD2 el punto se posiciona solo
      if (_inputBuffer == '0' && digit != '.') {
        _inputBuffer = digit;
      } else {
        _inputBuffer += digit;
      }
    });
  }

  void _onDoubleZero(String zeros) {
    _triggerHaptic();
    setState(() {
      if (_inputBuffer.isEmpty || _inputBuffer == '0') {
        _inputBuffer = '0';
      } else {
        _inputBuffer += zeros;
      }
    });
  }

  void _onBackspace() {
    _triggerHaptic();
    setState(() {
      if (_inputBuffer.isNotEmpty) {
        _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
      }
    });
  }

  void _onClearEntry() {
    _triggerHaptic();
    setState(() {
      _inputBuffer = '';
    });
  }

  void _onAllClear() {
    _triggerHaptic();
    setState(() {
      _inputBuffer = '';
      _accumulator = 0.0;
    });
  }

  void _addTapeOperation(String op, double amount, double newSubtotal, {String note = ''}) {
    final entry = TapeEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      operation: op,
      amount: amount,
      subtotalAfter: newSubtotal,
      note: note,
    );
    setState(() {
      _tape.add(entry);
      _accumulator = newSubtotal;
      _inputBuffer = '';
    });
    _scrollTapeToBottom();
  }

  void _onAddKey() {
    _triggerHaptic();
    final val = _parseCurrentInput();
    final newSub = _accumulator + val;
    _addTapeOperation('+', val, newSub);
  }

  void _onSubtractKey() {
    _triggerHaptic();
    final val = _parseCurrentInput();
    final newSub = _accumulator - val;
    _addTapeOperation('-', val, newSub);
  }

  void _onSubtotalKey() {
    _triggerHaptic();
    _addTapeOperation('ST', _accumulator, _accumulator);
  }

  void _onTotalKey() {
    _triggerHaptic();
    final total = _accumulator;
    _grandTotal += total;
    _addTapeOperation('TOTAL', total, 0.0);
    setState(() {
      _accumulator = 0.0;
      _inputBuffer = '';
    });
  }

  void _onTaxPlus() {
    _triggerHaptic();
    final base = _inputBuffer.isNotEmpty ? _parseCurrentInput() : _accumulator;
    if (base == 0) return;
    final taxAmount = base * (_taxRate / 100.0);
    final total = base + taxAmount;
    _addTapeOperation('TAX+ ($_taxRate%)', taxAmount, total);
  }

  void _onTaxMinus() {
    _triggerHaptic();
    final total = _inputBuffer.isNotEmpty ? _parseCurrentInput() : _accumulator;
    if (total == 0) return;
    final base = total / (1.0 + (_taxRate / 100.0));
    final taxAmount = total - base;
    _addTapeOperation('TAX- ($_taxRate%)', taxAmount, base);
  }

  void _showTaxRateDialog() {
    final ctrl = TextEditingController(text: _taxRate.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tasa de Impuesto / IVA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Porcentaje %', suffixText: '%'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val >= 0) {
                setState(() => _taxRate = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _onMarkUp() {
    _triggerHaptic();
    // MU: Mark up contable sobre el acumulador o entrada actual
    final cost = _accumulator;
    final percent = _parseCurrentInput();
    if (percent > 0 && percent < 100 && cost > 0) {
      final salePrice = cost / (1.0 - (percent / 100.0));
      _addTapeOperation('MU ($percent%)', salePrice - cost, salePrice);
    }
  }

  void _onGrandTotalRecall() {
    _triggerHaptic();
    _addTapeOperation('GT', _grandTotal, _grandTotal);
  }

  void _onMemoryAdd() {
    _triggerHaptic();
    final val = _inputBuffer.isNotEmpty ? _parseCurrentInput() : _accumulator;
    setState(() {
      _memoryValue += val;
      _inputBuffer = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('M+ : ${_memoryValue.toStringAsFixed(2)}'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF0EA5E9),
      ),
    );
  }

  void _onMemorySub() {
    _triggerHaptic();
    final val = _inputBuffer.isNotEmpty ? _parseCurrentInput() : _accumulator;
    setState(() {
      _memoryValue -= val;
      _inputBuffer = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('M- : ${_memoryValue.toStringAsFixed(2)}'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF0EA5E9),
      ),
    );
  }

  void _onMemoryRecall() {
    _triggerHaptic();
    setState(() {
      _inputBuffer = _memoryValue.toString();
    });
  }

  void _onMemoryClear() {
    _triggerHaptic();
    setState(() {
      _memoryValue = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memoria contable borrada (MC)'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black54,
      ),
    );
  }

  void _copyTapeToClipboard() {
    if (_tape.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('=== CINTA DE AUDITORÍA CONTABLE ===');
    for (int i = 0; i < _tape.length; i++) {
      final e = _tape[i];
      final notePart = e.note.isNotEmpty ? ' [${e.note}]' : '';
      buffer.writeln('${(i + 1).toString().padLeft(3, '0')} | ${e.operation.padRight(12)} | ${AccountingOps.formatCurrency(e.amount)} -> ${AccountingOps.formatCurrency(e.subtotalAfter)}$notePart');
    }
    buffer.writeln('===================================');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cinta de auditoría copiada al portapapeles'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF0EA5E9),
      ),
    );
  }

  void _saveTapeToHistory() {
    if (_tape.isEmpty) return;
    final last = _tape.last;
    widget.state.addAccountingHistoryItem(
      title: 'Sumadora Contable',
      expression: '${_tape.length} partidas registradas en cinta',
      result: AccountingOps.formatCurrency(last.subtotalAfter),
      numericResult: last.subtotalAfter,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cinta contable guardada en el historial'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF0EA5E9),
      ),
    );
  }

  void _clearTape() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Limpiar cinta de papel', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('¿Deseas vaciar todo el rollo de auditoría actual?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _tape.clear();
                _accumulator = 0.0;
                _inputBuffer = '';
              });
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // LÓGICA DE DEPRECIACIÓN
  // =========================================================================
  void _recalculateDepreciation() {
    final cost = double.tryParse(_depCostCtrl.text) ?? 0.0;
    final salvage = double.tryParse(_depSalvageCtrl.text) ?? 0.0;
    final life = int.tryParse(_depLifeCtrl.text) ?? 0;

    List<DepreciationYearEntry> result = [];
    if (_depMethod == 0) {
      result = AccountingOps.calculateStraightLineDepreciation(
        cost: cost,
        salvageValue: salvage,
        usefulLifeYears: life,
      );
    } else if (_depMethod == 1) {
      result = AccountingOps.calculateSydDepreciation(
        cost: cost,
        salvageValue: salvage,
        usefulLifeYears: life,
      );
    } else {
      result = AccountingOps.calculateDecliningBalanceDepreciation(
        cost: cost,
        salvageValue: salvage,
        usefulLifeYears: life,
        factor: 2.0,
      );
    }

    setState(() {
      _depreciationSchedule = result;
    });
  }

  // =========================================================================
  // LÓGICA DE NÓMINA
  // =========================================================================
  void _recalculatePayroll() {
    final base = double.tryParse(_payrollBaseCtrl.text) ?? 0.0;
    final bonus = double.tryParse(_payrollBonusCtrl.text) ?? 0.0;
    final tax = double.tryParse(_payrollTaxRateCtrl.text) ?? 0.0;
    final empSS = double.tryParse(_payrollEmployeeSSCtrl.text) ?? 0.0;
    final empySS = double.tryParse(_payrollEmployerSSCtrl.text) ?? 0.0;
    final other = double.tryParse(_payrollOtherDedCtrl.text) ?? 0.0;

    final res = AccountingOps.calculatePayroll(
      baseSalary: base,
      bonuses: bonus,
      taxRate: tax,
      employeeSocialSecurityRate: empSS,
      employerSocialSecurityRate: empySS,
      otherDeductions: other,
    );

    setState(() {
      _payrollResult = res;
    });
  }

  // =========================================================================
  // CONSTRUCCIÓN VISUAL
  // =========================================================================

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
                'Calculadora Contable',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'CONTABILIDAD',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0EA5E9),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Selector de Módulos Contables
          _buildModuleSelector(isDark),
          const SizedBox(height: 16),

          // Módulo Activo
          _buildActiveModuleCard(isDark, primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildModuleSelector(bool isDark) {
    final modules = [
      {'title': 'Sumadora & Cinta', 'icon': Icons.receipt_long_outlined},
      {'title': 'Depreciación Activos', 'icon': Icons.auto_graph_outlined},
      {'title': 'Ratios Contables', 'icon': Icons.pie_chart_outline},
      {'title': 'Nómina & Retenciones', 'icon': Icons.badge_outlined},
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0EA5E9).withValues(alpha: 0.5)
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      modules[idx]['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? const Color(0xFF0EA5E9)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      modules[idx]['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF0EA5E9)
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
        return _buildAddingMachineCard(isDark, primaryText, secondaryText);
      case 1:
        return _buildDepreciationCard(isDark, primaryText, secondaryText);
      case 2:
        return _buildRatiosCard(isDark, primaryText, secondaryText);
      case 3:
        return _buildPayrollCard(isDark, primaryText, secondaryText);
      default:
        return const SizedBox.shrink();
    }
  }

  // =========================================================================
  // 1. MÓDULO: SUMADORA CONTABLE CON CINTA DE AUDITORÍA
  // =========================================================================
  Widget _buildAddingMachineCard(bool isDark, Color primaryText, Color secondaryText) {
    final currentDisp = _inputBuffer.isEmpty
        ? (_accumulator == 0.0 ? '0' : AccountingOps.formatCurrency(_accumulator, decimals: _decimalPlaces < 0 ? 2 : _decimalPlaces, mode: _roundingMode))
        : (_addMode ? (_parseCurrentInput().toStringAsFixed(2)) : _inputBuffer);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        final tapeWidget = _buildTapeViewer(isDark, primaryText, secondaryText);
        final keypadWidget = _buildAddingMachineKeypad(isDark, currentDisp);

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: tapeWidget),
              const SizedBox(width: 16),
              Expanded(flex: 6, child: keypadWidget),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tapeWidget,
              const SizedBox(height: 16),
              keypadWidget,
            ],
          );
        }
      },
    );
  }

  Widget _buildTapeViewer(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera de la cinta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_outlined, size: 16, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 6),
                  Text(
                    'Cinta de Auditoría',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    tooltip: 'Copiar cinta',
                    color: secondaryText,
                    onPressed: _copyTapeToClipboard,
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    tooltip: 'Guardar en historial',
                    color: secondaryText,
                    onPressed: _saveTapeToHistory,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                    tooltip: 'Limpiar cinta',
                    color: Colors.redAccent,
                    onPressed: _clearTape,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 12),

          // Contenedor visual del rollo de papel
          Container(
            height: 240,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B0914) : const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: _tape.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined, size: 36, color: secondaryText.withValues(alpha: 0.4)),
                        const SizedBox(height: 8),
                        Text(
                          'El rollo de papel está vacío.\nIntroduce partidas con [+] y [-]',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: secondaryText.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _tapeScrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _tape.length,
                    itemBuilder: (context, index) {
                      final item = _tape[index];
                      final isTotal = item.operation == 'TOTAL';
                      final isSubtotal = item.operation == 'ST';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(index + 1).toString().padLeft(2, '0')}. ${item.operation}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: (isTotal || isSubtotal) ? FontWeight.bold : FontWeight.w500,
                                color: isTotal
                                    ? Colors.amberAccent
                                    : (isSubtotal ? const Color(0xFF0EA5E9) : secondaryText),
                              ),
                            ),
                            Text(
                              AccountingOps.formatCurrency(
                                item.amount,
                                decimals: _decimalPlaces < 0 ? 2 : _decimalPlaces,
                                mode: _roundingMode,
                              ),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: (isTotal || isSubtotal) ? FontWeight.bold : FontWeight.normal,
                                color: isTotal ? Colors.amberAccent : primaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),

          // Totalizador de cinta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gran Total (GT):',
                style: GoogleFonts.outfit(fontSize: 12, color: secondaryText),
              ),
              Text(
                AccountingOps.formatCurrency(_grandTotal, decimals: 2),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddingMachineKeypad(bool isDark, String currentDisp) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pantalla LCD de la sumadora
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF080612) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _addMode ? 'MODO ADD2' : 'DEC: ${_decimalPlaces < 0 ? "F" : _decimalPlaces}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: const Color(0xFF0EA5E9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: _showTaxRateDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'TAX: ${_taxRate.toStringAsFixed(0)}% ✎',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: const Color(0xFF0EA5E9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'REDONDEO: ${_roundingMode == AccountingRoundingMode.round54 ? "5/4" : (_roundingMode == AccountingRoundingMode.cut ? "CUT" : "UP")}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    currentDisp,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Selectores de decimales y redondeo
          Row(
            children: [
              // Selector Decimales
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isDense: true,
                      value: _decimalPlaces,
                      dropdownColor: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                      style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                      items: const [
                        DropdownMenuItem(value: -1, child: Text('F (Flotante)')),
                        DropdownMenuItem(value: 0, child: Text('0 Dec')),
                        DropdownMenuItem(value: 2, child: Text('2 Dec')),
                        DropdownMenuItem(value: 3, child: Text('3 Dec')),
                        DropdownMenuItem(value: 4, child: Text('4 Dec')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _decimalPlaces = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Modo ADD2 switch
              InkWell(
                onTap: () {
                  setState(() => _addMode = !_addMode);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _addMode ? const Color(0xFF0EA5E9).withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _addMode ? const Color(0xFF0EA5E9) : Colors.white24),
                  ),
                  child: Text(
                    'ADD2',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _addMode ? const Color(0xFF0EA5E9) : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Selector Redondeo
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AccountingRoundingMode>(
                      isDense: true,
                      value: _roundingMode,
                      dropdownColor: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                      style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                      items: const [
                        DropdownMenuItem(value: AccountingRoundingMode.round54, child: Text('5/4 Redondeo')),
                        DropdownMenuItem(value: AccountingRoundingMode.cut, child: Text('CUT Truncar')),
                        DropdownMenuItem(value: AccountingRoundingMode.up, child: Text('UP Techo')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _roundingMode = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Teclado Contable
          _buildKeypadRow([
            _key('TAX+ ($_taxRate%)', _onTaxPlus, isAction: true, color: const Color(0xFF0EA5E9)),
            _key('TAX- ($_taxRate%)', _onTaxMinus, isAction: true, color: const Color(0xFF0EA5E9)),
            _key('GT', _onGrandTotalRecall, isAction: true, color: Colors.purpleAccent),
            _key('MU', _onMarkUp, isAction: true, color: Colors.orangeAccent),
          ]),
          const SizedBox(height: 6),
          _buildKeypadRow([
            _key('MC', _onMemoryClear, isAction: true),
            _key('MR', _onMemoryRecall, isAction: true),
            _key('M-', _onMemorySub, isAction: true),
            _key('M+', _onMemoryAdd, isAction: true),
          ]),
          const SizedBox(height: 6),
          _buildKeypadRow([
            _key('CE', _onClearEntry, isAction: true, color: Colors.redAccent),
            _key('C', _onAllClear, isAction: true, color: Colors.redAccent),
            _key('⌫', _onBackspace, isAction: true),
            _key('ST', _onSubtotalKey, isAction: true, color: const Color(0xFF6366F1)),
          ]),
          const SizedBox(height: 6),
          _buildKeypadRow([
            _key('7', () => _onNumberKey('7')),
            _key('8', () => _onNumberKey('8')),
            _key('9', () => _onNumberKey('9')),
            _key('-', _onSubtractKey, isAction: true, color: Colors.indigoAccent),
          ]),
          const SizedBox(height: 6),
          _buildKeypadRow([
            _key('4', () => _onNumberKey('4')),
            _key('5', () => _onNumberKey('5')),
            _key('6', () => _onNumberKey('6')),
            _key('+', _onAddKey, isAction: true, color: const Color(0xFF10B981)),
          ]),
          const SizedBox(height: 6),
          _buildKeypadRow([
            _key('1', () => _onNumberKey('1')),
            _key('2', () => _onNumberKey('2')),
            _key('3', () => _onNumberKey('3')),
            _key('* TOTAL', _onTotalKey, isAction: true, flex: 1, color: Colors.amberAccent),
          ]),
          const SizedBox(height: 6),
          _buildKeypadRow([
            _key('0', () => _onNumberKey('0')),
            _key('00', () => _onDoubleZero('00')),
            _key('.', () => _onNumberKey('.')),
            _key('+=', _onAddKey, isAction: true, color: const Color(0xFF10B981)),
          ]),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<Widget> children) {
    return Row(
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: c))).toList(),
    );
  }

  Widget _key(String label, VoidCallback onTap, {bool isAction = false, Color? color, int flex = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: color != null
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isAction
                  ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                  : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color != null
                ? color.withValues(alpha: 0.4)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: label.length > 4 ? 10 : 13,
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. MÓDULO: DEPRECIACIÓN DE ACTIVOS FIJOS
  // =========================================================================
  Widget _buildDepreciationCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Depreciación de Activos Fijos',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                tooltip: 'Guardar en historial',
                color: const Color(0xFF0EA5E9),
                onPressed: () {
                  if (_depreciationSchedule.isEmpty) return;
                  widget.state.addAccountingHistoryItem(
                    title: 'Depreciación (${_depMethod == 0 ? "Línea Recta" : (_depMethod == 1 ? "SYD" : "DDB")})',
                    expression: 'Costo \$${_depCostCtrl.text}, Vida ${_depLifeCtrl.text} años',
                    result: 'Cuota año 1: ${AccountingOps.formatCurrency(_depreciationSchedule.first.depreciationExpense)}',
                    numericResult: _depreciationSchedule.first.depreciationExpense,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Depreciación guardada en el historial'), backgroundColor: Color(0xFF0EA5E9)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Selector de Método
          Row(
            children: [
              _depMethodChip(0, 'Línea Recta', isDark),
              const SizedBox(width: 8),
              _depMethodChip(1, 'Suma Dígitos (SYD)', isDark),
              const SizedBox(width: 8),
              _depMethodChip(2, 'Saldo Decreciente (DDB)', isDark),
            ],
          ),
          const SizedBox(height: 14),

          // Campos de entrada
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Costo de Adquisición',
                  controller: _depCostCtrl,
                  isDark: isDark,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  onChanged: (_) => _recalculateDepreciation(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: 'Valor de Rescate / Salvamento',
                  controller: _depSalvageCtrl,
                  isDark: isDark,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  onChanged: (_) => _recalculateDepreciation(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: 'Vida Útil (Años)',
                  controller: _depLifeCtrl,
                  isDark: isDark,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  onChanged: (_) => _recalculateDepreciation(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabla de Depreciación
          if (_depreciationSchedule.isNotEmpty) ...[
            Text(
              'Tabla Anual de Amortización & Valor en Libros:',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: primaryText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowHeight: 36,
                  dataRowMinHeight: 32,
                  dataRowMaxHeight: 34,
                  columns: const [
                    DataColumn(label: Text('Año')),
                    DataColumn(label: Text('Gasto Depreciación')),
                    DataColumn(label: Text('Deprec. Acumulada')),
                    DataColumn(label: Text('Valor en Libros')),
                  ],
                  rows: _depreciationSchedule.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text('Año ${e.year}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                        DataCell(Text(AccountingOps.formatCurrency(e.depreciationExpense), style: GoogleFonts.jetBrainsMono())),
                        DataCell(Text(AccountingOps.formatCurrency(e.accumulatedDepreciation), style: GoogleFonts.jetBrainsMono(color: Colors.amberAccent))),
                        DataCell(Text(AccountingOps.formatCurrency(e.bookValue), style: GoogleFonts.jetBrainsMono(color: const Color(0xFF10B981)))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _depMethodChip(int index, String label, bool isDark) {
    final isSelected = _depMethod == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _depMethod = index;
            _recalculateDepreciation();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.3 : 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0EA5E9) : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 3. MÓDULO: RATIOS CONTABLES
  // =========================================================================
  Widget _buildRatiosCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratios e Indicadores Financiero-Contables',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                tooltip: 'Guardar en historial',
                color: const Color(0xFF0EA5E9),
                onPressed: () {
                  final curAssets = double.tryParse(_curAssetsCtrl.text) ?? 0.0;
                  final curLiab = double.tryParse(_curLiabCtrl.text) ?? 0.0;
                  final cr = AccountingOps.currentRatio(curAssets, curLiab);
                  widget.state.addAccountingHistoryItem(
                    title: 'Ratios Contables',
                    expression: 'Razón Corriente (AC/PC)',
                    result: '${cr.toStringAsFixed(2)}x',
                    numericResult: cr,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ratios guardados en el historial'), backgroundColor: Color(0xFF0EA5E9)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sub-categorías
          Row(
            children: [
              _ratioCategoryChip(0, 'Liquidez & Capital', isDark),
              const SizedBox(width: 8),
              _ratioCategoryChip(1, 'Endeudamiento', isDark),
              const SizedBox(width: 8),
              _ratioCategoryChip(2, 'Rentabilidad', isDark),
            ],
          ),
          const SizedBox(height: 16),

          if (_ratiosSubCategory == 0) _buildLiquiditySection(isDark, primaryText, secondaryText),
          if (_ratiosSubCategory == 1) _buildDebtSection(isDark, primaryText, secondaryText),
          if (_ratiosSubCategory == 2) _buildProfitabilitySection(isDark, primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _ratioCategoryChip(int index, String label, bool isDark) {
    final isSelected = _ratiosSubCategory == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _ratiosSubCategory = index),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0EA5E9).withValues(alpha: isDark ? 0.3 : 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0EA5E9) : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquiditySection(bool isDark, Color primaryText, Color secondaryText) {
    final curAssets = double.tryParse(_curAssetsCtrl.text) ?? 0.0;
    final curLiab = double.tryParse(_curLiabCtrl.text) ?? 0.0;
    final inv = double.tryParse(_inventoryCtrl.text) ?? 0.0;

    final cr = AccountingOps.currentRatio(curAssets, curLiab);
    final qr = AccountingOps.quickRatio(curAssets, inv, curLiab);
    final wc = AccountingOps.workingCapital(curAssets, curLiab);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildInputField(label: 'Activo Circulante', controller: _curAssetsCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField(label: 'Pasivo Circulante', controller: _curLiabCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField(label: 'Inventarios', controller: _inventoryCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricTile('Razón Corriente (AC / PC)', '${cr.toStringAsFixed(2)}x', cr >= 1.5 ? 'Liquidez Saludable (> 1.5)' : (cr >= 1.0 ? 'Adecuada (1.0 - 1.5)' : 'Riesgo de liquidez (< 1.0)'), cr >= 1.5 ? const Color(0xFF10B981) : (cr >= 1.0 ? Colors.amberAccent : Colors.redAccent)),
        const SizedBox(height: 8),
        _buildMetricTile('Prueba Ácida ((AC - Inv) / PC)', '${qr.toStringAsFixed(2)}x', qr >= 1.0 ? 'Solvencia inmediata óptima (>= 1.0)' : 'Depende de venta de inventarios (< 1.0)', qr >= 1.0 ? const Color(0xFF10B981) : Colors.amberAccent),
        const SizedBox(height: 8),
        _buildMetricTile('Capital de Trabajo Neto (AC - PC)', AccountingOps.formatCurrency(wc), wc > 0 ? 'Fondo de maniobra positivo' : 'Déficit operativo de corto plazo', wc > 0 ? const Color(0xFF10B981) : Colors.redAccent),
      ],
    );
  }

  Widget _buildDebtSection(bool isDark, Color primaryText, Color secondaryText) {
    final totLiab = double.tryParse(_totLiabCtrl.text) ?? 0.0;
    final totAssets = double.tryParse(_totAssetsCtrl.text) ?? 0.0;
    final equity = double.tryParse(_equityCtrl.text) ?? 0.0;

    final dr = AccountingOps.debtRatio(totLiab, totAssets);
    final fl = AccountingOps.financialLeverage(totLiab, equity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildInputField(label: 'Pasivo Total', controller: _totLiabCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField(label: 'Activo Total', controller: _totAssetsCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField(label: 'Patrimonio Neto', controller: _equityCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricTile('Ratio de Endeudamiento (PT / AT)', '${dr.toStringAsFixed(1)}%', dr <= 50.0 ? 'Endeudamiento bajo/moderado (<= 50%)' : (dr <= 70.0 ? 'Apalancamiento alto (50% - 70%)' : 'Alto compromiso financiero (> 70%)'), dr <= 50.0 ? const Color(0xFF10B981) : (dr <= 70.0 ? Colors.amberAccent : Colors.redAccent)),
        const SizedBox(height: 8),
        _buildMetricTile('Apalancamiento Financiero (PT / PN)', '${fl.toStringAsFixed(2)}x', fl <= 1.0 ? 'Patrimonio supera deuda' : 'Deuda supera capital propio', fl <= 1.0 ? const Color(0xFF10B981) : Colors.amberAccent),
      ],
    );
  }

  Widget _buildProfitabilitySection(bool isDark, Color primaryText, Color secondaryText) {
    final netInc = double.tryParse(_netIncomeCtrl.text) ?? 0.0;
    final totAssets = double.tryParse(_totAssetsCtrl.text) ?? 0.0;
    final equity = double.tryParse(_equityCtrl.text) ?? 0.0;

    final roa = AccountingOps.returnOnAssets(netInc, totAssets);
    final roe = AccountingOps.returnOnEquity(netInc, equity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildInputField(label: 'Utilidad Neta', controller: _netIncomeCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField(label: 'Activos Totales', controller: _totAssetsCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField(label: 'Patrimonio Neto', controller: _equityCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricTile('ROA (Rendimiento sobre Activos)', '${roa.toStringAsFixed(2)}%', roa >= 5.0 ? 'Rendimiento sobre activos atractivo (>= 5%)' : 'Eficiencia de activos baja (< 5%)', roa >= 5.0 ? const Color(0xFF10B981) : Colors.amberAccent),
        const SizedBox(height: 8),
        _buildMetricTile('ROE (Rendimiento sobre Patrimonio)', '${roe.toStringAsFixed(2)}%', roe >= 15.0 ? 'Excelente rentabilidad para socios (>= 15%)' : (roe >= 8.0 ? 'Rentabilidad aceptable' : 'Bajo retorno sobre capital'), roe >= 15.0 ? const Color(0xFF10B981) : Colors.amberAccent),
      ],
    );
  }

  Widget _buildMetricTile(String title, String value, String desc, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(desc, style: GoogleFonts.outfit(fontSize: 11, color: badgeColor)),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. MÓDULO: NÓMINA Y RETENCIONES
  // =========================================================================
  Widget _buildPayrollCard(bool isDark, Color primaryText, Color secondaryText) {
    final res = _payrollResult;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cálculo de Nómina & Retenciones',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                tooltip: 'Guardar en historial',
                color: const Color(0xFF0EA5E9),
                onPressed: () {
                  if (res == null) return;
                  widget.state.addAccountingHistoryItem(
                    title: 'Nómina',
                    expression: 'Bruto \$${res["grossSalary"]?.toStringAsFixed(2)}',
                    result: 'Neto: \$${res["netSalary"]?.toStringAsFixed(2)}',
                    numericResult: res["netSalary"],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nómina guardada en el historial'), backgroundColor: Color(0xFF0EA5E9)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Campos de nómina
          Row(
            children: [
              Expanded(child: _buildInputField(label: 'Salario Base', controller: _payrollBaseCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => _recalculatePayroll())),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(label: 'Bonos / Extras', controller: _payrollBonusCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => _recalculatePayroll())),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(label: 'Ret. Impuestos (%)', controller: _payrollTaxRateCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => _recalculatePayroll())),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildInputField(label: 'Seg. Social Empleado (%)', controller: _payrollEmployeeSSCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => _recalculatePayroll())),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(label: 'Seg. Social Patronal (%)', controller: _payrollEmployerSSCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => _recalculatePayroll())),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(label: 'Otras Deducciones (\$) ', controller: _payrollOtherDedCtrl, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText, onChanged: (_) => _recalculatePayroll())),
            ],
          ),
          const SizedBox(height: 16),

          if (res != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                children: [
                  _payrollRow('Salario Bruto Total', AccountingOps.formatCurrency(res['grossSalary'] ?? 0), isDark ? Colors.white : Colors.black87, bold: true),
                  const Divider(height: 14),
                  _payrollRow('(-) Retención Impuestos (ISR)', AccountingOps.formatCurrency(res['taxWithholding'] ?? 0), Colors.redAccent),
                  _payrollRow('(-) Cuota Seguridad Social Empleado', AccountingOps.formatCurrency(res['employeeSocialSecurity'] ?? 0), Colors.redAccent),
                  if ((res['otherDeductions'] ?? 0) > 0)
                    _payrollRow('(-) Otras Deducciones', AccountingOps.formatCurrency(res['otherDeductions'] ?? 0), Colors.redAccent),
                  const Divider(height: 14),
                  _payrollRow('(=) SALARIO NETO A PAGAR', AccountingOps.formatCurrency(res['netSalary'] ?? 0), const Color(0xFF10B981), bold: true, fontSize: 15),
                  const Divider(height: 14),
                  _payrollRow('Aporte Patronal (Carga Social)', AccountingOps.formatCurrency(res['employerSocialSecurity'] ?? 0), Colors.amberAccent),
                  _payrollRow('COSTO TOTAL LABORAL EMPRESA', AccountingOps.formatCurrency(res['totalEmployerCost'] ?? 0), const Color(0xFF0EA5E9), bold: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _payrollRow(String label, String value, Color color, {bool bold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.w400)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
