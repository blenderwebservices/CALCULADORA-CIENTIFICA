import 'dart:math' as math;

/// Modos de redondeo contable habituales en calculadoras de escritorio
enum AccountingRoundingMode {
  round54, // 5/4: Redondeo estándar (>= 5 hacia arriba, < 5 hacia abajo)
  cut,     // CUT: Truncamiento directo hacia abajo
  up,      // UP: Redondeo hacia arriba (techo)
}

/// Fila para la tabla de amortización/depreciación de activos
class DepreciationYearEntry {
  final int year;
  final double depreciationExpense;
  final double accumulatedDepreciation;
  final double bookValue;

  const DepreciationYearEntry({
    required this.year,
    required this.depreciationExpense,
    required this.accumulatedDepreciation,
    required this.bookValue,
  });
}

/// Clase utilitaria con las fórmulas y cálculos contables
class AccountingOps {
  // =========================================================================
  // 1. REDONDEO Y FORMATEO CONTABLE
  // =========================================================================

  /// Aplica el modo de redondeo contable especificado a [value] con [decimals] decimales.
  static double applyRounding(
    double value, {
    int decimals = 2,
    AccountingRoundingMode mode = AccountingRoundingMode.round54,
  }) {
    if (value.isNaN || value.isInfinite) return value;
    final factor = math.pow(10, decimals).toDouble();

    switch (mode) {
      case AccountingRoundingMode.round54:
        return (value * factor).roundToDouble() / factor;
      case AccountingRoundingMode.cut:
        if (value >= 0) {
          return (value * factor).floorToDouble() / factor;
        } else {
          return (value * factor).ceilToDouble() / factor;
        }
      case AccountingRoundingMode.up:
        if (value >= 0) {
          return (value * factor).ceilToDouble() / factor;
        } else {
          return (value * factor).floorToDouble() / factor;
        }
    }
  }

  /// Formatea un número como divisa o valor contable con comas de miles y decimales
  static String formatCurrency(
    double value, {
    int decimals = 2,
    String symbol = '\$',
    AccountingRoundingMode mode = AccountingRoundingMode.round54,
  }) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';

    final rounded = applyRounding(value, decimals: decimals, mode: mode);
    final isNegative = rounded < 0;
    final absVal = rounded.abs();

    final parts = absVal.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Agregar comas de miles
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

    final symPrefix = symbol.isNotEmpty ? '$symbol ' : '';
    return isNegative ? '-$symPrefix$formattedNumber' : '$symPrefix$formattedNumber';
  }

  // =========================================================================
  // 2. DEPRECIACIÓN DE ACTIVOS FIJOS
  // =========================================================================

  /// Depreciación por Línea Recta (Straight Line)
  /// Retorna la cuota anual y la tabla año a año.
  static List<DepreciationYearEntry> calculateStraightLineDepreciation({
    required double cost,
    required double salvageValue,
    required int usefulLifeYears,
  }) {
    if (cost <= 0 || usefulLifeYears <= 0 || salvageValue < 0 || salvageValue > cost) {
      return [];
    }

    final depreciableBase = cost - salvageValue;
    final annualExpense = depreciableBase / usefulLifeYears;

    final entries = <DepreciationYearEntry>[];
    double accumulated = 0.0;
    double currentBookValue = cost;

    for (int y = 1; y <= usefulLifeYears; y++) {
      accumulated += annualExpense;
      currentBookValue = cost - accumulated;
      if (y == usefulLifeYears) {
        currentBookValue = salvageValue;
      }
      entries.add(
        DepreciationYearEntry(
          year: y,
          depreciationExpense: annualExpense,
          accumulatedDepreciation: accumulated,
          bookValue: currentBookValue,
        ),
      );
    }

    return entries;
  }

  /// Depreciación por Suma de Dígitos de los Años (Sum-of-the-Years'-Digits / SYD)
  static List<DepreciationYearEntry> calculateSydDepreciation({
    required double cost,
    required double salvageValue,
    required int usefulLifeYears,
  }) {
    if (cost <= 0 || usefulLifeYears <= 0 || salvageValue < 0 || salvageValue > cost) {
      return [];
    }

    final depreciableBase = cost - salvageValue;
    final syd = (usefulLifeYears * (usefulLifeYears + 1)) / 2;

    final entries = <DepreciationYearEntry>[];
    double accumulated = 0.0;

    for (int y = 1; y <= usefulLifeYears; y++) {
      final remainingYears = usefulLifeYears - y + 1;
      final expense = depreciableBase * (remainingYears / syd);
      accumulated += expense;
      final bookValue = (y == usefulLifeYears) ? salvageValue : (cost - accumulated);

      entries.add(
        DepreciationYearEntry(
          year: y,
          depreciationExpense: expense,
          accumulatedDepreciation: accumulated,
          bookValue: bookValue,
        ),
      );
    }

    return entries;
  }

  /// Depreciación por Saldo Decreciente (Declining Balance)
  /// factor: 2.0 para Doble Saldo Decreciente (DDB), 1.5 para 150% DB
  static List<DepreciationYearEntry> calculateDecliningBalanceDepreciation({
    required double cost,
    required double salvageValue,
    required int usefulLifeYears,
    double factor = 2.0,
  }) {
    if (cost <= 0 || usefulLifeYears <= 0 || salvageValue < 0 || salvageValue > cost) {
      return [];
    }

    final rate = (1.0 / usefulLifeYears) * factor;
    final entries = <DepreciationYearEntry>[];
    double accumulated = 0.0;
    double currentBookValue = cost;

    for (int y = 1; y <= usefulLifeYears; y++) {
      double expense = currentBookValue * rate;

      // No depreciar por debajo del valor residual
      if (currentBookValue - expense < salvageValue) {
        expense = currentBookValue - salvageValue;
      }
      if (expense < 0) expense = 0.0;

      accumulated += expense;
      currentBookValue -= expense;

      entries.add(
        DepreciationYearEntry(
          year: y,
          depreciationExpense: expense,
          accumulatedDepreciation: accumulated,
          bookValue: currentBookValue,
        ),
      );
    }

    return entries;
  }

  // =========================================================================
  // 3. RATIOS CONTABLES Y FINANCIEROS
  // =========================================================================

  /// Razón Corriente = Activo Corriente / Pasivo Corriente
  static double currentRatio(double currentAssets, double currentLiabilities) {
    if (currentLiabilities <= 0) return 0.0;
    return currentAssets / currentLiabilities;
  }

  /// Prueba Ácida = (Activo Corriente - Inventarios) / Pasivo Corriente
  static double quickRatio(double currentAssets, double inventory, double currentLiabilities) {
    if (currentLiabilities <= 0) return 0.0;
    return (currentAssets - inventory) / currentLiabilities;
  }

  /// Capital de Trabajo Neto = Activo Corriente - Pasivo Corriente
  static double workingCapital(double currentAssets, double currentLiabilities) {
    return currentAssets - currentLiabilities;
  }

  /// Ratio de Endeudamiento = Pasivo Total / Activo Total
  static double debtRatio(double totalLiabilities, double totalAssets) {
    if (totalAssets <= 0) return 0.0;
    return (totalLiabilities / totalAssets) * 100.0;
  }

  /// Apalancamiento Financiero = Pasivo Total / Patrimonio Neto
  static double financialLeverage(double totalLiabilities, double totalEquity) {
    if (totalEquity <= 0) return 0.0;
    return totalLiabilities / totalEquity;
  }

  /// Rendimiento sobre Activos (ROA) = (Utilidad Neta / Activos Totales) * 100
  static double returnOnAssets(double netIncome, double totalAssets) {
    if (totalAssets <= 0) return 0.0;
    return (netIncome / totalAssets) * 100.0;
  }

  /// Rendimiento sobre Patrimonio (ROE) = (Utilidad Neta / Patrimonio Neto) * 100
  static double returnOnEquity(double netIncome, double totalEquity) {
    if (totalEquity <= 0) return 0.0;
    return (netIncome / totalEquity) * 100.0;
  }

  // =========================================================================
  // 4. NÓMINA Y RETENCIONES CONTABLES
  // =========================================================================

  static Map<String, double> calculatePayroll({
    required double baseSalary,
    double bonuses = 0.0,
    double taxRate = 10.0, // Retención de Impuesto sobre la Renta (%)
    double employeeSocialSecurityRate = 5.0, // Aporte seguridad social empleado (%)
    double employerSocialSecurityRate = 15.0, // Aporte patronal seguridad social (%)
    double otherDeductions = 0.0,
  }) {
    final grossSalary = baseSalary + bonuses;
    if (grossSalary <= 0) {
      return {
        'grossSalary': 0.0,
        'taxWithholding': 0.0,
        'employeeSocialSecurity': 0.0,
        'totalEmployeeDeductions': 0.0,
        'netSalary': 0.0,
        'employerSocialSecurity': 0.0,
        'totalEmployerCost': 0.0,
      };
    }

    final taxWithholding = grossSalary * (taxRate / 100.0);
    final employeeSS = grossSalary * (employeeSocialSecurityRate / 100.0);
    final totalDeductions = taxWithholding + employeeSS + otherDeductions;
    final netSalary = grossSalary - totalDeductions;

    final employerSS = grossSalary * (employerSocialSecurityRate / 100.0);
    final totalEmployerCost = grossSalary + employerSS;

    return {
      'grossSalary': grossSalary,
      'taxWithholding': taxWithholding,
      'employeeSocialSecurity': employeeSS,
      'otherDeductions': otherDeductions,
      'totalEmployeeDeductions': totalDeductions,
      'netSalary': netSalary,
      'employerSocialSecurity': employerSS,
      'totalEmployerCost': totalEmployerCost,
    };
  }
}
