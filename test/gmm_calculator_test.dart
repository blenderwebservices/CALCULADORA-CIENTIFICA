import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_matrix_calculator/models/gmm_insurance_models.dart';
import 'package:scientific_matrix_calculator/utils/gmm_calculator_ops.dart';

void main() {
  group('GmmCalculatorOps Tests', () {
    test('Retorna no cubierto cuando el gasto no supera el deducible', () {
      const input = GmmCalculationInput(
        totalClaim: 20000.0,
        nonCoveredExpenses: 2000.0,
        contractedDeductible: 25000.0,
        contractedCoinsurance: 10.0,
        hasStopLoss: true,
        stopLossAmount: 50000.0,
      );

      final result = GmmCalculatorOps.calculate(input);

      expect(result.isClaimCovered, isFalse);
      expect(result.eligibleExpenses, 18000.0);
      expect(result.appliedDeductible, 25000.0);
      expect(result.totalInsurerPayment, 0.0);
      expect(result.totalInsuredPayment, 20000.0);
      expect(result.nonCoverageReason, contains('no supera el deducible'));
    });

    test('Cálculo estándar de siniestro por enfermedad (sin topar coaseguro)', () {
      const input = GmmCalculationInput(
        totalClaim: 150000.0,
        nonCoveredExpenses: 10000.0,
        contractedDeductible: 25000.0,
        contractedCoinsurance: 10.0,
        hasStopLoss: true,
        stopLossAmount: 50000.0,
      );

      final result = GmmCalculatorOps.calculate(input);

      expect(result.isClaimCovered, isTrue);
      expect(result.eligibleExpenses, 140000.0);
      expect(result.appliedDeductible, 25000.0);
      expect(result.coinsuranceBase, 115000.0);
      expect(result.appliedCoinsuranceRate, 10.0);
      expect(result.calculatedCoinsurance, 11500.0);
      expect(result.effectiveCoinsurance, 11500.0);
      expect(result.isStopLossReached, isFalse);
      expect(result.stopLossSavings, 0.0);
      expect(result.totalInsurerPayment, 103500.0);
      expect(result.totalInsuredPayment, 46500.0);
      expect(result.totalInsurerPayment + result.totalInsuredPayment, 150000.0);
    });

    test('Cálculo de siniestro con Tope de Coaseguro (Stop Loss alcanzado)', () {
      const input = GmmCalculationInput(
        totalClaim: 800000.0,
        nonCoveredExpenses: 0.0,
        contractedDeductible: 25000.0,
        contractedCoinsurance: 10.0,
        hasStopLoss: true,
        stopLossAmount: 50000.0,
      );

      final result = GmmCalculatorOps.calculate(input);

      expect(result.isClaimCovered, isTrue);
      expect(result.coinsuranceBase, 775000.0);
      expect(result.calculatedCoinsurance, 77500.0);
      expect(result.effectiveCoinsurance, 50000.0); // Limitado al tope
      expect(result.isStopLossReached, isTrue);
      expect(result.stopLossSavings, 27500.0); // 77500 - 50000
      expect(result.totalInsurerPayment, 725000.0);
      expect(result.totalInsuredPayment, 75000.0); // 25000 deducible + 50000 coaseguro
      expect(result.totalInsurerPayment + result.totalInsuredPayment, 800000.0);
    });

    test('Beneficio de Cero Deducible por Accidente', () {
      const input = GmmCalculationInput(
        totalClaim: 100000.0,
        nonCoveredExpenses: 5000.0,
        contractedDeductible: 30000.0,
        contractedCoinsurance: 10.0,
        hasStopLoss: true,
        stopLossAmount: 60000.0,
        isAccident: true,
        hasZeroDeductibleBenefit: true,
      );

      final result = GmmCalculatorOps.calculate(input);

      expect(result.isClaimCovered, isTrue);
      expect(result.appliedDeductible, 0.0); // Deducible perdonado
      expect(result.eligibleExpenses, 95000.0);
      expect(result.coinsuranceBase, 95000.0);
      expect(result.calculatedCoinsurance, 9500.0);
      expect(result.effectiveCoinsurance, 9500.0);
      expect(result.totalInsurerPayment, 85500.0);
      expect(result.totalInsuredPayment, 14500.0); // 5000 no cubiertos + 0 deducible + 9500 coaseguro
    });

    test('Penalización de coaseguro por atención fuera de red', () {
      const input = GmmCalculationInput(
        totalClaim: 200000.0,
        nonCoveredExpenses: 0.0,
        contractedDeductible: 20000.0,
        contractedCoinsurance: 10.0,
        hasStopLoss: false,
        isOutOfNetwork: true,
        outOfNetworkPenalty: 10.0, // Sube de 10% a 20%
      );

      final result = GmmCalculatorOps.calculate(input);

      expect(result.isClaimCovered, isTrue);
      expect(result.appliedCoinsuranceRate, 20.0); // 10% + 10%
      expect(result.coinsuranceBase, 180000.0);
      expect(result.calculatedCoinsurance, 36000.0); // 180,000 * 20%
      expect(result.totalInsuredPayment, 56000.0); // 20000 + 36000
      expect(result.totalInsurerPayment, 144000.0);
    });

    test('Perfiles de aseguradoras mexicanas cargan correctamente', () {
      final profiles = GmmInsurerProfile.mexicanInsurers;
      expect(profiles.length, greaterThanOrEqualTo(8));

      final gnp = profiles.firstWhere((p) => p.id == 'gnp');
      expect(gnp.name, 'GNP Seguros');
      expect(gnp.defaultCoinsurance, 10.0);
      expect(gnp.defaultStopLoss, 55000.0);

      final axa = profiles.firstWhere((p) => p.id == 'axa');
      expect(axa.name, 'AXA Seguros');

      final metlife = profiles.firstWhere((p) => p.id == 'metlife');
      expect(metlife.name, 'MetLife México');
    });

    test('Formateador de pesos mexicanos formatMxn', () {
      expect(GmmCalculatorOps.formatMxn(1234567.89), '\$1,234,567.89');
      expect(GmmCalculatorOps.formatMxn(0), '\$0.00');
      expect(GmmCalculatorOps.formatMxn(-500.5), '-\$500.50');
    });
  });
}
