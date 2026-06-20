class MatrixOps {
  /// Suma dos matrices de dimensiones iguales.
  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    final int rows = a.length;
    final int cols = a[0].length;
    if (b.length != rows || b[0].length != cols) {
      throw ArgumentError('Las dimensiones deben ser idénticas.');
    }
    final List<List<double>> result = List.generate(rows, (_) => List.filled(cols, 0.0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result[r][c] = a[r][c] + b[r][c];
      }
    }
    return result;
  }

  /// Resta dos matrices de dimensiones iguales.
  static List<List<double>> subtract(List<List<double>> a, List<List<double>> b) {
    final int rows = a.length;
    final int cols = a[0].length;
    if (b.length != rows || b[0].length != cols) {
      throw ArgumentError('Las dimensiones deben ser idénticas.');
    }
    final List<List<double>> result = List.generate(rows, (_) => List.filled(cols, 0.0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result[r][c] = a[r][c] - b[r][c];
      }
    }
    return result;
  }

  /// Multiplica dos matrices si las columnas de A coinciden con las filas de B.
  static List<List<double>> multiply(List<List<double>> a, List<List<double>> b) {
    final int aRows = a.length;
    final int aCols = a[0].length;
    final int bRows = b.length;
    final int bCols = b[0].length;
    if (aCols != bRows) {
      throw ArgumentError('Columnas de A ($aCols) deben coincidir con filas de B ($bRows).');
    }
    final List<List<double>> result = List.generate(aRows, (_) => List.filled(bCols, 0.0));
    for (int r = 0; r < aRows; r++) {
      for (int c = 0; c < bCols; c++) {
        double sum = 0.0;
        for (int k = 0; k < aCols; k++) {
          sum += a[r][k] * b[k][c];
        }
        result[r][c] = sum;
      }
    }
    return result;
  }

  /// Calcula el determinante (solo para cuadradas de 1x1 y 2x2).
  static double determinant(List<List<double>> m) {
    final int rows = m.length;
    final int cols = m[0].length;
    if (rows != cols) {
      throw ArgumentError('El determinante solo está definido para matrices cuadradas.');
    }
    if (rows == 1) {
      return m[0][0];
    } else if (rows == 2) {
      return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    } else {
      throw UnsupportedError('Solo soportado hasta matrices de 2x2.');
    }
  }

  /// Calcula la inversa de una matriz (1x1 o 2x2).
  static List<List<double>> inverse(List<List<double>> m) {
    final int rows = m.length;
    final int cols = m[0].length;
    if (rows != cols) {
      throw ArgumentError('La inversa solo está definida para matrices cuadradas.');
    }
    if (rows == 1) {
      if (m[0][0] == 0.0) {
        throw ArgumentError('Matriz singular. No tiene inversa.');
      }
      return [[1.0 / m[0][0]]];
    } else if (rows == 2) {
      final double det = determinant(m);
      if (det == 0.0) {
        throw ArgumentError('Determinante es 0. Matriz singular.');
      }
      return [
        [m[1][1] / det, -m[0][1] / det],
        [-m[1][0] / det, m[0][0] / det]
      ];
    } else {
      throw UnsupportedError('Solo soportado hasta matrices de 2x2.');
    }
  }

  /// Calcula la transpuesta de una matriz.
  static List<List<double>> transpose(List<List<double>> m) {
    final int rows = m.length;
    final int cols = m[0].length;
    final List<List<double>> result = List.generate(cols, (_) => List.filled(rows, 0.0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result[c][r] = m[r][c];
      }
    }
    return result;
  }

  /// Multiplica una matriz por un escalar k.
  static List<List<double>> scalarMultiply(List<List<double>> m, double k) {
    final int rows = m.length;
    final int cols = m[0].length;
    final List<List<double>> result = List.generate(rows, (_) => List.filled(cols, 0.0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result[r][c] = k * m[r][c];
      }
    }
    return result;
  }

  /// Formatea un double con un número máximo de decimales o notación científica.
  static String formatDouble(double val) {
    if (val.isNaN) return 'NaN';
    if (val.isInfinite) return 'Error';
    if (val == 0.0) return '0';
    if (val.abs() > 1e12 || val.abs() < 1e-6) {
      return val.toStringAsExponential(6);
    }
    // Formatear decimales y quitar ceros innecesarios
    String str = val.toStringAsFixed(10);
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      if (str.endsWith('.')) {
        str = str.substring(0, str.length - 1);
      }
    }
    // Reemplazar punto por coma si es necesario (el original usa separadores locales, mantengamos el formato con puntos de miles si es deseado o un string limpio)
    // Para simplificar, usemo el formato estándar del sistema.
    return str;
  }

  /// Formatea la matriz para representarla de manera amigable en el historial.
  /// Ej: [[1.0, 2.0], [3.0, 4.0]] -> "[1, 2; 3, 4]"
  static String formatMatrix(List<List<double>> m) {
    return '[' + m.map((row) => row.map((val) => formatDouble(val)).join(', ')).join('; ') + ']';
  }
}
