import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_matrix_calculator/utils/math_parser.dart';
import 'package:scientific_matrix_calculator/utils/matrix_ops.dart';
import 'package:scientific_matrix_calculator/utils/accounting_ops.dart';

void main() {
  group('MathParser Tests', () {
    test('Evaluates functions with variable x', () {
      final postfix = MathParser.parseToPostfix('x^2 - 4');
      final resultAt3 = MathParser.evaluatePostfix(postfix, 'RAD', xValue: 3.0);
      expect(resultAt3, equals(5.0));

      final resultAtMinus2 = MathParser.evaluatePostfix(postfix, 'RAD', xValue: -2.0);
      expect(resultAtMinus2, equals(0.0));
    });

    test('Evaluates trigonometric functions with variable x', () {
      final postfix = MathParser.parseToPostfix('sin(x)');
      final resultRad = MathParser.evaluatePostfix(postfix, 'RAD', xValue: math.pi / 2);
      expect(resultRad, closeTo(1.0, 1e-6));

      final resultDeg = MathParser.evaluatePostfix(postfix, 'DEG', xValue: 30.0);
      expect(resultDeg, closeTo(0.5, 1e-6));
    });

    test('Supports implicit multiplication with variable x', () {
      final postfix = MathParser.parseToPostfix('2x + 1');
      final result = MathParser.evaluatePostfix(postfix, 'RAD', xValue: 5.0);
      expect(result, equals(11.0));
    });

    test('Supports abs(x)', () {
      final postfix = MathParser.parseToPostfix('abs(x)');
      expect(MathParser.evaluatePostfix(postfix, 'RAD', xValue: -42.5), equals(42.5));
      expect(MathParser.evaluatePostfix(postfix, 'RAD', xValue: 18.0), equals(18.0));
    });

    test('Safe evaluation in quietMode for discontinuities', () {
      final postfix = MathParser.parseToPostfix('1/x');
      final result = MathParser.evaluatePostfix(postfix, 'RAD', xValue: 0.0, quietMode: true);
      expect(result.isNaN || result.isInfinite, isTrue);
    });
  });

  group('MatrixOps Tests up to 4x4', () {
    test('Calculates 4x4 determinant', () {
      final mat4x4 = [
        [1.0, 0.0, 2.0, -1.0],
        [3.0, 0.0, 0.0, 5.0],
        [2.0, 1.0, 4.0, -3.0],
        [1.0, 0.0, 5.0, 0.0],
      ];
      final det = MatrixOps.determinant(mat4x4);
      // Laplace cofactor along 2nd column:
      // -1 * det of [[1, 2, -1], [3, 0, 5], [1, 5, 0]]
      // = -1 * (1*(0 - 25) - 2*(0 - 5) - 1*(15 - 0))
      // = -1 * (-25 + 10 - 15) = -1 * (-30) = 30
      expect(det, closeTo(30.0, 1e-5));
    });

    test('Calculates 4x4 inverse and verifies identity', () {
      final mat4x4 = [
        [2.0, 1.0, 0.0, 0.0],
        [0.0, 1.0, 2.0, 0.0],
        [0.0, 0.0, 3.0, 1.0],
        [1.0, 0.0, 0.0, 2.0],
      ];
      final inv = MatrixOps.inverse(mat4x4);
      expect(inv, isNotNull);

      final identity = MatrixOps.multiply(mat4x4, inv);
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (i == j) {
            expect(identity[i][j], closeTo(1.0, 1e-5));
          } else {
            expect(identity[i][j], closeTo(0.0, 1e-5));
          }
        }
      }
    });

    test('Non-square matrix multiplication (e.g. 2x3 by 3x4 = 2x4)', () {
      final a = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
      ];
      final b = [
        [7.0, 8.0],
        [9.0, 1.0],
        [2.0, 3.0],
      ];
      final c = MatrixOps.multiply(a, b);
      expect(c.length, equals(2));
      expect(c[0].length, equals(2));
      expect(c[0][0], equals(1 * 7 + 2 * 9 + 3 * 2)); // 7 + 18 + 6 = 31
      expect(c[0][1], equals(1 * 8 + 2 * 1 + 3 * 3)); // 8 + 2 + 9 = 19
    });
  });

  group('Business Calculations Formulas', () {
    test('Loan monthly payment formula', () {
      const double p = 100000.0;
      const double r = 0.12; // 12% anual
      const int months = 12;

      final double monthlyRate = r / 12.0; // 0.01
      final double monthlyPayment = p * (monthlyRate * math.pow(1 + monthlyRate, months)) / (math.pow(1 + monthlyRate, months) - 1);

      expect(monthlyPayment, closeTo(8884.88, 0.1));
    });

    test('Break-even calculation formula', () {
      const double fixedCosts = 50000.0;
      const double price = 200.0;
      const double varCost = 100.0;

      final double units = fixedCosts / (price - varCost);
      expect(units, equals(500.0));
      final double revenue = units * price;
      expect(revenue, equals(100000.0));
    });

    test('Margin and Markup formulas', () {
      const double cost = 100.0;
      const double sale = 150.0;

      final double margin = ((sale - cost) / sale) * 100;
      final double markup = ((sale - cost) / cost) * 100;

      expect(margin, closeTo(33.333, 0.01));
      expect(markup, closeTo(50.0, 0.01));
    });
  });

  group('AccountingOps Tests', () {
    test('Straight-line depreciation calculates equal annual expenses', () {
      final entries = AccountingOps.calculateStraightLineDepreciation(
        cost: 100000.0,
        salvageValue: 10000.0,
        usefulLifeYears: 5,
      );

      expect(entries.length, equals(5));
      // Base depreciable = 90,000 / 5 = 18,000 anual
      for (final e in entries) {
        expect(e.depreciationExpense, closeTo(18000.0, 0.01));
      }
      expect(entries.last.accumulatedDepreciation, closeTo(90000.0, 0.01));
      expect(entries.last.bookValue, closeTo(10000.0, 0.01));
    });

    test('SYD depreciation allocates higher expense in early years', () {
      final entries = AccountingOps.calculateSydDepreciation(
        cost: 100000.0,
        salvageValue: 10000.0,
        usefulLifeYears: 5,
      );

      expect(entries.length, equals(5));
      // SYD factor sum = 5+4+3+2+1 = 15. Base = 90,000.
      // Year 1: 90,000 * (5/15) = 30,000
      expect(entries[0].depreciationExpense, closeTo(30000.0, 0.01));
      // Year 2: 90,000 * (4/15) = 24,000
      expect(entries[1].depreciationExpense, closeTo(24000.0, 0.01));
      // Final book value equals salvage
      expect(entries.last.bookValue, closeTo(10000.0, 0.01));
    });

    test('Declining balance depreciation honors salvage value threshold', () {
      final entries = AccountingOps.calculateDecliningBalanceDepreciation(
        cost: 10000.0,
        salvageValue: 1500.0,
        usefulLifeYears: 5,
        factor: 2.0, // 40% rate
      );

      expect(entries.length, equals(5));
      // Book value never drops below salvage
      for (final e in entries) {
        expect(e.bookValue, greaterThanOrEqualTo(1500.0 - 0.01));
      }
    });

    test('Financial accounting ratios calculate accurately', () {
      // Current ratio: 150,000 / 75,000 = 2.0
      expect(AccountingOps.currentRatio(150000.0, 75000.0), equals(2.0));

      // Quick ratio: (150,000 - 30,000) / 75,000 = 1.6
      expect(AccountingOps.quickRatio(150000.0, 30000.0, 75000.0), equals(1.6));

      // Working capital: 150,000 - 75,000 = 75,000
      expect(AccountingOps.workingCapital(150000.0, 75000.0), equals(75000.0));

      // Debt ratio: (200,000 / 500,000) * 100 = 40%
      expect(AccountingOps.debtRatio(200000.0, 500000.0), equals(40.0));

      // ROA: (50,000 / 500,000) * 100 = 10%
      expect(AccountingOps.returnOnAssets(50000.0, 500000.0), equals(10.0));
    });

    test('Payroll calculations computes deductions and net correctly', () {
      final payroll = AccountingOps.calculatePayroll(
        baseSalary: 20000.0,
        bonuses: 2000.0,
        taxRate: 10.0, // 2,200
        employeeSocialSecurityRate: 5.0, // 1,100
        employerSocialSecurityRate: 15.0, // 3,300
        otherDeductions: 500.0,
      );

      expect(payroll['grossSalary'], equals(22000.0));
      expect(payroll['taxWithholding'], equals(2200.0));
      expect(payroll['employeeSocialSecurity'], equals(1100.0));
      expect(payroll['totalEmployeeDeductions'], equals(3800.0));
      expect(payroll['netSalary'], equals(18200.0));
      expect(payroll['totalEmployerCost'], equals(25300.0));
    });

    test('Accounting rounding modes behave according to standards', () {
      // 5/4 rounding
      expect(AccountingOps.applyRounding(12.345, decimals: 2, mode: AccountingRoundingMode.round54), equals(12.35));
      expect(AccountingOps.applyRounding(12.344, decimals: 2, mode: AccountingRoundingMode.round54), equals(12.34));

      // CUT rounding (truncate)
      expect(AccountingOps.applyRounding(12.349, decimals: 2, mode: AccountingRoundingMode.cut), equals(12.34));

      // UP rounding (ceil)
      expect(AccountingOps.applyRounding(12.341, decimals: 2, mode: AccountingRoundingMode.up), equals(12.35));

      // Currency formatting
      final formatted = AccountingOps.formatCurrency(1250350.75, decimals: 2);
      expect(formatted, equals('\$ 1,250,350.75'));
    });
  });
}
