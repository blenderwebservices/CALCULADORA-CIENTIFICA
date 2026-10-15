import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gmm_insurance_models.dart';
import '../models/history_item.dart';
import '../utils/calculator_state.dart';
import '../utils/gmm_calculator_ops.dart';
import '../widgets/glass_container.dart';

class GmmScreen extends StatefulWidget {
  final CalculatorState state;

  const GmmScreen({super.key, required this.state});

  @override
  State<GmmScreen> createState() => _GmmScreenState();
}

class _GmmScreenState extends State<GmmScreen> {
  // Aseguradora activa
  GmmInsurerProfile _selectedProfile = GmmInsurerProfile.mexicanInsurers[0];

  // Controladores de texto
  final TextEditingController _totalClaimCtrl = TextEditingController(text: '150000');
  final TextEditingController _nonCoveredCtrl = TextEditingController(text: '10000');
  final TextEditingController _deductibleCtrl = TextEditingController(text: '26000');
  final TextEditingController _coinsuranceCtrl = TextEditingController(text: '10');
  final TextEditingController _stopLossCtrl = TextEditingController(text: '55000');
  final TextEditingController _outOfNetworkPenaltyCtrl = TextEditingController(text: '10');

  // Condiciones de póliza
  bool _hasStopLoss = true;
  bool _isAccident = false;
  bool _hasZeroDeductibleBenefit = true;
  bool _isOutOfNetwork = false;

  // Resultado
  GmmCalculationResult? _result;

  @override
  void initState() {
    super.initState();
    _applyProfileDefaults(_selectedProfile);
  }

  @override
  void dispose() {
    _totalClaimCtrl.dispose();
    _nonCoveredCtrl.dispose();
    _deductibleCtrl.dispose();
    _coinsuranceCtrl.dispose();
    _stopLossCtrl.dispose();
    _outOfNetworkPenaltyCtrl.dispose();
    super.dispose();
  }

  void _applyProfileDefaults(GmmInsurerProfile profile) {
    setState(() {
      _selectedProfile = profile;
      _deductibleCtrl.text = profile.defaultDeductible.toStringAsFixed(0);
      _coinsuranceCtrl.text = profile.defaultCoinsurance.toStringAsFixed(0);
      _stopLossCtrl.text = profile.defaultStopLoss.toStringAsFixed(0);
      _hasStopLoss = profile.hasStopLossByDefault;
      _hasZeroDeductibleBenefit = profile.hasZeroDeductibleAccident;
      _outOfNetworkPenaltyCtrl.text = profile.outOfNetworkCoinsurancePenalty.toStringAsFixed(0);
      _calculate();
    });
  }

  void _calculate() {
    final double totalClaim = double.tryParse(_totalClaimCtrl.text.replaceAll(',', '')) ?? 0.0;
    final double nonCovered = double.tryParse(_nonCoveredCtrl.text.replaceAll(',', '')) ?? 0.0;
    final double deductible = double.tryParse(_deductibleCtrl.text.replaceAll(',', '')) ?? 0.0;
    final double coinsurance = double.tryParse(_coinsuranceCtrl.text.replaceAll(',', '')) ?? 10.0;
    final double stopLoss = double.tryParse(_stopLossCtrl.text.replaceAll(',', '')) ?? 50000.0;
    final double penalty = double.tryParse(_outOfNetworkPenaltyCtrl.text.replaceAll(',', '')) ?? 10.0;

    final input = GmmCalculationInput(
      totalClaim: totalClaim,
      nonCoveredExpenses: nonCovered,
      contractedDeductible: deductible,
      contractedCoinsurance: coinsurance,
      hasStopLoss: _hasStopLoss,
      stopLossAmount: stopLoss,
      isAccident: _isAccident,
      hasZeroDeductibleBenefit: _hasZeroDeductibleBenefit,
      isOutOfNetwork: _isOutOfNetwork,
      outOfNetworkPenalty: penalty,
    );

    setState(() {
      _result = GmmCalculatorOps.calculate(input);
    });
  }

  void _saveToHistory() {
    if (_result == null || !_result!.isClaimCovered) return;

    final String insurerName = _selectedProfile.name;
    final String expr = '$insurerName | Gasto: ${GmmCalculatorOps.formatMxn(_result!.totalClaim)} (Ded: ${GmmCalculatorOps.formatMxn(_result!.appliedDeductible)}, Coas: ${_result!.appliedCoinsuranceRate.toStringAsFixed(0)}%)';
    final String res = 'Aseguradora: ${GmmCalculatorOps.formatMxn(_result!.totalInsurerPayment)} (${_result!.insurerPercentage.toStringAsFixed(1)}%) | Asegurado: ${GmmCalculatorOps.formatMxn(_result!.totalInsuredPayment)}';

    widget.state.historyList.insert(
      0,
      HistoryItem(
        type: 'business',
        expression: expr,
        result: res,
        numericResult: _result!.totalInsurerPayment,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulación de GMM guardada en el historial', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copySummaryToClipboard() {
    if (_result == null) return;

    final buffer = StringBuffer();
    buffer.writeln('=== SIMULACIÓN GASTOS MÉDICOS MAYORES (MÉXICO) ===');
    buffer.writeln('Aseguradora: ${_selectedProfile.name} (${_selectedProfile.policyExample})');
    buffer.writeln('Tipo de Siniestro: ${_isAccident ? "Accidente" : "Enfermedad"}');
    buffer.writeln('Atención: ${_isOutOfNetwork ? "Fuera de Red / Convenio (+${_outOfNetworkPenaltyCtrl.text}%)" : "En Red Hospitalaria"}');
    buffer.writeln('--------------------------------------------------');
    buffer.writeln('Gasto Total Presentado: ${GmmCalculatorOps.formatMxn(_result!.totalClaim)}');
    buffer.writeln('Gastos No Cubiertos:    ${GmmCalculatorOps.formatMxn(_result!.nonCoveredExpenses)}');
    buffer.writeln('Gasto Procedente:       ${GmmCalculatorOps.formatMxn(_result!.eligibleExpenses)}');
    buffer.writeln('Deducible Aplicado:     ${GmmCalculatorOps.formatMxn(_result!.appliedDeductible)} ${_isAccident && _hasZeroDeductibleBenefit ? "(Exento por accidente)" : ""}');
    buffer.writeln('Base Coaseguro:         ${GmmCalculatorOps.formatMxn(_result!.coinsuranceBase)}');
    buffer.writeln('Coaseguro (${_result!.appliedCoinsuranceRate.toStringAsFixed(0)}%):    ${GmmCalculatorOps.formatMxn(_result!.effectiveCoinsurance)} ${_result!.isStopLossReached ? "(Topado - Ahorro: ${GmmCalculatorOps.formatMxn(_result!.stopLossSavings)})" : ""}');
    buffer.writeln('--------------------------------------------------');
    buffer.writeln('PAGO ASEGURADORA:       ${GmmCalculatorOps.formatMxn(_result!.totalInsurerPayment)} (${_result!.insurerPercentage.toStringAsFixed(1)}%)');
    buffer.writeln('PAGO ASEGURADO:         ${GmmCalculatorOps.formatMxn(_result!.totalInsuredPayment)} (${_result!.insuredPercentage.toStringAsFixed(1)}%)');
    buffer.writeln('==================================================');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resumen copiado al portapapeles', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 2),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Selector de Aseguradoras Mexicanas
          _buildInsurerSelector(isDark, primaryText, secondaryText),
          const SizedBox(height: 16),

          // 2. Formulario de Parámetros y Tarjeta de Resultados
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                // Modo Escritorio: Dos columnas
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildInputsCard(isDark, primaryText, secondaryText),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: _buildResultsSection(isDark, primaryText, secondaryText),
                    ),
                  ],
                );
              } else {
                // Modo Móvil: Vertical apilado
                return Column(
                  children: [
                    _buildInputsCard(isDark, primaryText, secondaryText),
                    const SizedBox(height: 16),
                    _buildResultsSection(isDark, primaryText, secondaryText),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // 3. Guía Educativa del Mercado Mexicano de GMM
          _buildEducationGuide(isDark, primaryText, secondaryText),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. SELECTOR VISUAL DE ASEGURADORAS
  // =========================================================================
  Widget _buildInsurerSelector(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedProfile.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _selectedProfile.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.shield_outlined, color: _selectedProfile.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aseguradoras en México (Pólizas GMM)',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
                    ),
                    Text(
                      'Selecciona tu compañía para precargar deducibles y topes habituales',
                      style: GoogleFonts.outfit(fontSize: 12, color: secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Chips desplazables de aseguradoras
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: GmmInsurerProfile.mexicanInsurers.map((profile) {
                final isSelected = profile.id == _selectedProfile.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => _applyProfileDefaults(profile),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? profile.primaryColor.withValues(alpha: isDark ? 0.25 : 0.15)
                            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? profile.primaryColor : (isDark ? Colors.white12 : Colors.black12),
                          width: isSelected ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: profile.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profile.name,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                              color: isSelected ? primaryText : secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Información de la aseguradora seleccionada
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: _selectedProfile.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(fontSize: 12, color: secondaryText),
                      children: [
                        TextSpan(
                          text: '${_selectedProfile.name} (${_selectedProfile.policyExample}): ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryText),
                        ),
                        TextSpan(text: _selectedProfile.notes),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. TARJETA DE FORMULARIO DE ENTRADAS
  // =========================================================================
  Widget _buildInputsCard(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: const Color(0xFFC084FC), size: 22),
              const SizedBox(width: 8),
              Text(
                'Datos del Siniestro y Póliza',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gasto Total Reclamado
          _buildNumericField(
            label: 'Gasto Total Reclamado (Hospital + Honorarios)',
            controller: _totalClaimCtrl,
            isDark: isDark,
            primaryText: primaryText,
            prefix: '\$ ',
            onChanged: _calculate,
          ),
          const SizedBox(height: 12),

          // Gastos No Cubiertos
          _buildNumericField(
            label: 'Gastos No Cubiertos (Exclusiones / Insumos personales)',
            controller: _nonCoveredCtrl,
            isDark: isDark,
            primaryText: primaryText,
            prefix: '\$ ',
            onChanged: _calculate,
          ),
          const SizedBox(height: 16),

          // Deducible Contratado y Chips de Presets
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumericField(
                label: 'Deducible Contratado (\$)',
                controller: _deductibleCtrl,
                isDark: isDark,
                primaryText: primaryText,
                prefix: '\$ ',
                onChanged: _calculate,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedProfile.commonDeductibles.map((d) {
                  final text = '\$${(d / 1000).toStringAsFixed(0)}k';
                  final isCurrent = (double.tryParse(_deductibleCtrl.text) ?? 0.0) == d;
                  return InkWell(
                    onTap: () {
                      _deductibleCtrl.text = d.toStringAsFixed(0);
                      _calculate();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFC084FC).withValues(alpha: 0.25)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFFC084FC) : (isDark ? Colors.white12 : Colors.black12),
                        ),
                      ),
                      child: Text(
                        text,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? const Color(0xFFC084FC) : secondaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Coaseguro Contratado y Chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumericField(
                label: 'Coaseguro Contratado (%)',
                controller: _coinsuranceCtrl,
                isDark: isDark,
                primaryText: primaryText,
                suffix: '%',
                onChanged: _calculate,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: _selectedProfile.commonCoinsurances.map((c) {
                  final text = '${c.toStringAsFixed(0)}%';
                  final isCurrent = (double.tryParse(_coinsuranceCtrl.text) ?? 0.0) == c;
                  return InkWell(
                    onTap: () {
                      _coinsuranceCtrl.text = c.toStringAsFixed(0);
                      _calculate();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFF6366F1) : (isDark ? Colors.white12 : Colors.black12),
                        ),
                      ),
                      child: Text(
                        text,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? const Color(0xFF6366F1) : secondaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Switch y Campo de Tope de Coaseguro (Stop Loss)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '¿Póliza con Tope de Coaseguro (Stop Loss)?',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: primaryText),
                ),
              ),
              Switch.adaptive(
                value: _hasStopLoss,
                activeTrackColor: const Color(0xFF10B981),
                onChanged: (val) {
                  setState(() {
                    _hasStopLoss = val;
                    _calculate();
                  });
                },
              ),
            ],
          ),
          if (_hasStopLoss) ...[
            const SizedBox(height: 6),
            _buildNumericField(
              label: 'Monto del Tope de Coaseguro (\$)',
              controller: _stopLossCtrl,
              isDark: isDark,
              primaryText: primaryText,
              prefix: '\$ ',
              onChanged: _calculate,
            ),
          ],
          const SizedBox(height: 14),

          const Divider(height: 20),

          // Switch: ¿Es Accidente?
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isAccident
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isAccident ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : (isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.personal_injury_outlined, size: 18, color: _isAccident ? const Color(0xFFF59E0B) : secondaryText),
                          const SizedBox(width: 6),
                          Text(
                            '¿Es consecuencia de Accidente?',
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: primaryText),
                          ),
                        ],
                      ),
                      if (_isAccident)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            _hasZeroDeductibleBenefit ? 'Aplica beneficio de Cero Deducible (\$0)' : 'Deducible contratado aplica normalmente',
                            style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFF59E0B)),
                          ),
                        ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isAccident,
                  activeTrackColor: const Color(0xFFF59E0B),
                  onChanged: (val) {
                    setState(() {
                      _isAccident = val;
                      _calculate();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Switch: ¿Atención fuera de Red / Hospital no convenido?
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isOutOfNetwork
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOutOfNetwork ? const Color(0xFFEF4444).withValues(alpha: 0.4) : (isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wrong_location_outlined, size: 18, color: _isOutOfNetwork ? const Color(0xFFEF4444) : secondaryText),
                          const SizedBox(width: 6),
                          Text(
                            '¿Atención Fuera de Red / Convenio?',
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: primaryText),
                          ),
                        ],
                      ),
                      if (_isOutOfNetwork)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'Penalización de +${_outOfNetworkPenaltyCtrl.text}% en coaseguro',
                            style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFEF4444)),
                          ),
                        ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isOutOfNetwork,
                  activeTrackColor: const Color(0xFFEF4444),
                  onChanged: (val) {
                    setState(() {
                      _isOutOfNetwork = val;
                      _calculate();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. SECCIÓN DE RESULTADOS VISUALES
  // =========================================================================
  Widget _buildResultsSection(bool isDark, Color primaryText, Color secondaryText) {
    if (_result == null) {
      return GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Ingresa los datos para calcular la liquidación.',
            style: GoogleFonts.outfit(color: secondaryText),
          ),
        ),
      );
    }

    final res = _result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tarjeta Principal de Resumen
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado con estado y botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: res.isClaimCovered
                          ? const Color(0xFF10B981).withValues(alpha: 0.18)
                          : const Color(0xFFEF4444).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: res.isClaimCovered ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          res.isClaimCovered ? Icons.check_circle_outline : Icons.error_outline,
                          size: 14,
                          color: res.isClaimCovered ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          res.isClaimCovered ? 'Siniestro Indemnizable' : 'No Supera Deducible',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: res.isClaimCovered ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botones Guardar y Copiar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        tooltip: 'Guardar en Historial',
                        color: const Color(0xFFC084FC),
                        onPressed: res.isClaimCovered ? _saveToHistory : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 19),
                        tooltip: 'Copiar desglose',
                        color: const Color(0xFF6366F1),
                        onPressed: _copySummaryToClipboard,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mensaje de No Cobertura si aplica
              if (!res.isClaimCovered) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    res.nonCoverageReason ?? 'El monto reclamado no supera el deducible aplicable.',
                    style: GoogleFonts.outfit(fontSize: 13, color: primaryText),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Dos Cajas Principales: Pago Aseguradora vs Desembolso Asegurado
              Row(
                children: [
                  // Aseguradora
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF10B981).withValues(alpha: 0.2), const Color(0xFF047857).withValues(alpha: 0.08)]
                              : [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paga Aseguradora',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF059669)),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              GmmCalculatorOps.formatMxn(res.totalInsurerPayment),
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF065F46),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${res.insurerPercentage.toStringAsFixed(1)}% del total',
                            style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Asegurado
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFFF59E0B).withValues(alpha: 0.2), const Color(0xFFB45309).withValues(alpha: 0.08)]
                              : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pagas Tú (Asegurado)',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFD97706)),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              GmmCalculatorOps.formatMxn(res.totalInsuredPayment),
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF92400E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${res.insuredPercentage.toStringAsFixed(1)}% del total',
                            style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Barra Visual de Distribución
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución Gráfica del Gasto:',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryText),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        children: [
                          if (res.totalInsurerPayment > 0)
                            Expanded(
                              flex: (res.totalInsurerPayment).round(),
                              child: Container(
                                color: const Color(0xFF10B981),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          if (res.appliedDeductible > 0)
                            Expanded(
                              flex: (res.appliedDeductible).round(),
                              child: Container(
                                color: const Color(0xFFF59E0B),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          if (res.effectiveCoinsurance > 0)
                            Expanded(
                              flex: (res.effectiveCoinsurance).round(),
                              child: Container(
                                color: const Color(0xFF6366F1),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          if (res.nonCoveredExpenses > 0)
                            Expanded(
                              flex: (res.nonCoveredExpenses).round(),
                              child: Container(
                                color: const Color(0xFFEF4444),
                                child: const SizedBox.expand(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Leyenda de la barra
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildLegendDot(const Color(0xFF10B981), 'Aseguradora (${res.insurerPercentage.toStringAsFixed(0)}%)', secondaryText),
                      _buildLegendDot(const Color(0xFFF59E0B), 'Deducible', secondaryText),
                      _buildLegendDot(const Color(0xFF6366F1), 'Coaseguro', secondaryText),
                      if (res.nonCoveredExpenses > 0)
                        _buildLegendDot(const Color(0xFFEF4444), 'No Cubiertos', secondaryText),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Alerta de Ahorro por Tope de Coaseguro si aplica
              if (res.isStopLossReached) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: Color(0xFF818CF8), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Tope de Coaseguro Activado!',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: primaryText),
                            ),
                            Text(
                              'El coaseguro calculado era ${GmmCalculatorOps.formatMxn(res.calculatedCoinsurance)}. Gracias al tope contratado, ahorraste ${GmmCalculatorOps.formatMxn(res.stopLossSavings)}.',
                              style: GoogleFonts.outfit(fontSize: 12, color: secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Desglose Numérico Detallado
              const Divider(height: 20),
              Text(
                'Desglose Paso a Paso del Siniestro',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: primaryText),
              ),
              const SizedBox(height: 10),

              _buildDetailRow('Gasto Total Presentado:', GmmCalculatorOps.formatMxn(res.totalClaim), primaryText, isBold: true),
              if (res.nonCoveredExpenses > 0)
                _buildDetailRow('(-) Gastos No Procedentes / Exclusiones:', '-${GmmCalculatorOps.formatMxn(res.nonCoveredExpenses)}', const Color(0xFFEF4444)),
              _buildDetailRow('(=) Gasto Procedente:', GmmCalculatorOps.formatMxn(res.eligibleExpenses), primaryText),
              _buildDetailRow(
                '(-) Deducible Aplicado:',
                res.appliedDeductible == 0 && _isAccident
                    ? '\$0.00 (Exento por Accidente)'
                    : '-${GmmCalculatorOps.formatMxn(res.appliedDeductible)}',
                const Color(0xFFF59E0B),
              ),
              _buildDetailRow('(=) Base para Coaseguro:', GmmCalculatorOps.formatMxn(res.coinsuranceBase), primaryText),
              _buildDetailRow(
                '(-) Coaseguro Efectivo (${res.appliedCoinsuranceRate.toStringAsFixed(0)}%):',
                '-${GmmCalculatorOps.formatMxn(res.effectiveCoinsurance)}',
                const Color(0xFF6366F1),
              ),
              const Divider(height: 16),
              _buildDetailRow(
                'TOTAL CUBIERTO POR ASEGURADORA:',
                GmmCalculatorOps.formatMxn(res.totalInsurerPayment),
                const Color(0xFF10B981),
                isBold: true,
                fontSize: 14,
              ),
              _buildDetailRow(
                'DESEMBOLSO TOTAL DEL ASEGURADO:',
                GmmCalculatorOps.formatMxn(res.totalInsuredPayment),
                const Color(0xFFF59E0B),
                isBold: true,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 4. GUÍA EDUCATIVA INTERACTIVA DE GMM EN MÉXICO
  // =========================================================================
  Widget _buildEducationGuide(bool isDark, Color primaryText, Color secondaryText) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                'Glosario Clave de Gastos Médicos Mayores en México',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: primaryText),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            '1. Deducible',
            'Cantidad fija en pesos que debes pagar antes de que la aseguradora empiece a cubrir. Si el siniestro cuesta menos que el deducible, la aseguradora no indemniza. En casi todas las aseguradoras (GNP, AXA, MetLife, SMNYL) el deducible queda en \$0 si se trata de un accidente cubierto.',
            primaryText,
            secondaryText,
          ),
          _buildGuideItem(
            '2. Coaseguro y Tope de Coaseguro (Stop Loss)',
            'Porcentaje (habitualmente 10% o 15%) que pagas del monto restante tras restar el deducible. El **Tope de Coaseguro** es tu mayor protección financiera: fija una cantidad máxima en pesos (ej. \$50,000 MXN) que pagarás por coaseguro, sin importar qué tan millonaria sea la cuenta del hospital.',
            primaryText,
            secondaryText,
          ),
          _buildGuideItem(
            '3. Red Hospitalaria y Nivel de Póliza',
            'Cada aseguradora categoriza los hospitales privados en niveles (ej. Básica, Intermedia, Alta Especialidad como ABC, Médica Sur, Ángeles). Si te atiendes en un nivel superior al contratado o fuera de la red, se penaliza sumando típicamente un +10% o +20% extra al coaseguro.',
            primaryText,
            secondaryText,
          ),
          _buildGuideItem(
            '4. Gastos No Cubiertos y Tabulador Médico',
            'La aseguradora rechaza insumos no médicos (cama extra de acompañante, alimentos especiales, llamadas, pañales). Además, los honorarios médicos se reembolsan con base en un "Tabulador"; si el cirujano cobra por encima de dicho tabulador, la diferencia corre 100% por cuenta del paciente.',
            primaryText,
            secondaryText,
          ),
        ],
      ),
    );
  }

  // --- HELPERS VISUALES ---

  Widget _buildGuideItem(String title, String description, Color primaryText, Color secondaryText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: primaryText)),
          const SizedBox(height: 2),
          Text(description, style: GoogleFonts.outfit(fontSize: 12, color: secondaryText, height: 1.35)),
        ],
      ),
    );
  }

  Widget _buildNumericField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required Color primaryText,
    String? prefix,
    String? suffix,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: primaryText),
            decoration: InputDecoration(
              prefixText: prefix,
              prefixStyle: GoogleFonts.outfit(color: const Color(0xFFC084FC), fontWeight: FontWeight.bold),
              suffixText: suffix,
              suffixStyle: GoogleFonts.outfit(color: const Color(0xFFC084FC), fontWeight: FontWeight.bold),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor, {bool isBold = false, double fontSize = 12.5}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
                color: isBold ? null : Colors.grey[400],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.outfit(fontSize: 11, color: textColor)),
      ],
    );
  }
}
