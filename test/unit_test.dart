import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_matrix_calculator/utils/math_parser.dart';
import 'package:scientific_matrix_calculator/utils/matrix_ops.dart';

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
      expect(result == null || result.isNaN || result.isInfinite, isTrue);
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

      final identity = MatrixOps.multiply(mat4x4, inv!);
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
}
