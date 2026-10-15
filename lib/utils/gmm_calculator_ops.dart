import 'dart:math' as math;
import '../models/gmm_insurance_models.dart';

/// Operaciones y motor de cálculo para pólizas de Gastos Médicos Mayores en México
class GmmCalculatorOps {
  /// Ejecuta el cálculo actuarial y contractual de cobertura de un siniestro de GMM
  static GmmCalculationResult calculate(GmmCalculationInput input) {
    final double totalClaim = math.max(0.0, input.totalClaim);
    final double nonCovered = math.min(totalClaim, math.max(0.0, input.nonCoveredExpenses));
    final double eligibleExpenses = totalClaim - nonCovered;

    // 1. Determinar deducible aplicable
    double appliedDeductible = input.contractedDeductible;
    if (input.isAccident && input.hasZeroDeductibleBenefit) {
      appliedDeductible = 0.0;
    }

    // 2. Si el gasto total es cero
    if (totalClaim <= 0) {
      return GmmCalculationResult(
        isClaimCovered: false,
        nonCoverageReason: 'Ingrese un monto de gasto médico para calcular la cobertura.',
        totalClaim: 0.0,
        nonCoveredExpenses: 0.0,
        eligibleExpenses: 0.0,
        appliedDeductible: appliedDeductible,
        coinsuranceBase: 0.0,
        appliedCoinsuranceRate: input.contractedCoinsurance,
        calculatedCoinsurance: 0.0,
        effectiveCoinsurance: 0.0,
        isStopLossReached: false,
        stopLossSavings: 0.0,
        totalInsuredPayment: 0.0,
        totalInsurerPayment: 0.0,
        insuredPercentage: 100.0,
        insurerPercentage: 0.0,
      );
    }

    // 3. Evaluar procedencia: ¿Gasto procedente supera el deducible?
    if (eligibleExpenses <= appliedDeductible) {
      final reason = appliedDeductible > 0
          ? 'El gasto procedente (${formatMxn(eligibleExpenses)}) no supera el deducible (${formatMxn(appliedDeductible)}). La aseguradora no indemniza este evento.'
          : 'El gasto médico no es suficiente para generar reclamación.';

      return GmmCalculationResult(
        isClaimCovered: false,
        nonCoverageReason: reason,
        totalClaim: totalClaim,
        nonCoveredExpenses: nonCovered,
        eligibleExpenses: eligibleExpenses,
        appliedDeductible: appliedDeductible,
        coinsuranceBase: 0.0,
        appliedCoinsuranceRate: input.contractedCoinsurance,
        calculatedCoinsurance: 0.0,
        effectiveCoinsurance: 0.0,
        isStopLossReached: false,
        stopLossSavings: 0.0,
        totalInsuredPayment: totalClaim,
        totalInsurerPayment: 0.0,
        insuredPercentage: 100.0,
        insurerPercentage: 0.0,
      );
    }

    // 4. Base indemnizable para coaseguro
    final double coinsuranceBase = eligibleExpenses - appliedDeductible;

    // 5. Tasa de coaseguro (con penalización si se atendió fuera de red)
    double effectiveRate = input.contractedCoinsurance;
    if (input.isOutOfNetwork) {
      effectiveRate += input.outOfNetworkPenalty;
    }
    effectiveRate = math.max(0.0, effectiveRate);

    // 6. Cálculo preliminar de coaseguro
    final double calculatedCoinsurance = coinsuranceBase * (effectiveRate / 100.0);

    // 7. Aplicación del Tope de Coaseguro (Stop Loss)
    double effectiveCoinsurance = calculatedCoinsurance;
    bool isStopLossReached = false;
    double stopLossSavings = 0.0;

    if (input.hasStopLoss && input.stopLossAmount > 0) {
      if (calculatedCoinsurance > input.stopLossAmount) {
        effectiveCoinsurance = input.stopLossAmount;
        isStopLossReached = true;
        stopLossSavings = calculatedCoinsurance - input.stopLossAmount;
      }
    }

    // 8. Totales de pago
    final double totalInsurerPayment = math.max(0.0, eligibleExpenses - appliedDeductible - effectiveCoinsurance);
    final double totalInsuredPayment = nonCovered + appliedDeductible + effectiveCoinsurance;

    final double insuredPercentage = totalClaim > 0 ? (totalInsuredPayment / totalClaim) * 100.0 : 0.0;
    final double insurerPercentage = totalClaim > 0 ? (totalInsurerPayment / totalClaim) * 100.0 : 0.0;

    return GmmCalculationResult(
      isClaimCovered: true,
      nonCoverageReason: null,
      totalClaim: totalClaim,
      nonCoveredExpenses: nonCovered,
      eligibleExpenses: eligibleExpenses,
      appliedDeductible: appliedDeductible,
      coinsuranceBase: coinsuranceBase,
      appliedCoinsuranceRate: effectiveRate,
      calculatedCoinsurance: calculatedCoinsurance,
      effectiveCoinsurance: effectiveCoinsurance,
      isStopLossReached: isStopLossReached,
      stopLossSavings: stopLossSavings,
      totalInsuredPayment: totalInsuredPayment,
      totalInsurerPayment: totalInsurerPayment,
      insuredPercentage: insuredPercentage,
      insurerPercentage: insurerPercentage,
    );
  }

  /// Formatea un valor numérico como moneda en pesos mexicanos (MXN)
  static String formatMxn(double amount, {int decimals = 2}) {
    if (amount.isNaN) return '\$0.00';
    if (amount.isInfinite) return amount.isNegative ? '-\$∞' : '\$∞';

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    final formattedNumber = decimalPart.isNotEmpty
        ? '${buffer.toString()}.$decimalPart'
        : buffer.toString();

    return isNegative ? '-\$$formattedNumber' : '\$$formattedNumber';
  }
}
