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

  /// Calcula el determinante (para matrices cuadradas de 1x1 hasta 4x4 y mayores).
  static double determinant(List<List<double>> m) {
    final int rows = m.length;
    final int cols = m[0].length;
    if (rows != cols) {
      throw ArgumentError('El determinante solo está definido para matrices cuadradas.');
    }
    return _detRecursive(m);
  }

  static double _detRecursive(List<List<double>> m) {
    final int n = m.length;
    if (n == 1) return m[0][0];
    if (n == 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    if (n == 3) {
      return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
          m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
          m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
    }
    // Expansión por cofactores para 4x4 o mayor
    double det = 0.0;
    for (int c = 0; c < n; c++) {
      final sub = _createSubmatrix(m, 0, c);
      final sign = (c % 2 == 0) ? 1.0 : -1.0;
      det += sign * m[0][c] * _detRecursive(sub);
    }
    return det;
  }

  static List<List<double>> _createSubmatrix(List<List<double>> m, int excludeRow, int excludeCol) {
    final int n = m.length;
    final List<List<double>> sub = [];
    for (int r = 0; r < n; r++) {
      if (r == excludeRow) continue;
      final List<double> row = [];
      for (int c = 0; c < n; c++) {
        if (c == excludeCol) continue;
        row.add(m[r][c]);
      }
      sub.add(row);
    }
    return sub;
  }

  /// Calcula la inversa de una matriz (cuadrada de 1x1 hasta 4x4).
  static List<List<double>> inverse(List<List<double>> m) {
    final int n = m.length;
    if (n == 0 || m[0].length != n) {
      throw ArgumentError('La inversa solo está definida para matrices cuadradas.');
    }

    final double det = determinant(m);
    if (det.abs() < 1e-12) {
      throw ArgumentError('Determinante es 0. Matriz singular, no tiene inversa.');
    }

    if (n == 1) {
      return [[1.0 / m[0][0]]];
    } else if (n == 2) {
      return [
        [m[1][1] / det, -m[0][1] / det],
        [-m[1][0] / det, m[0][0] / det]
      ];
    }

    // Eliminación Gauss-Jordan con pivoteo parcial para n >= 3
    final int cols = 2 * n;
    final List<List<double>> aug = List.generate(
      n,
      (r) => List.generate(cols, (c) {
        if (c < n) return m[r][c];
        return (c - n == r) ? 1.0 : 0.0;
      }),
    );

    for (int i = 0; i < n; i++) {
      // Buscar fila pivote con el valor absoluto máximo
      int pivotRow = i;
      double maxVal = aug[i][i].abs();
      for (int r = i + 1; r < n; r++) {
        if (aug[r][i].abs() > maxVal) {
          maxVal = aug[r][i].abs();
          pivotRow = r;
        }
      }

      if (maxVal < 1e-12) {
        throw ArgumentError('Matriz singular. No tiene inversa.');
      }

      // Intercambiar filas
      if (pivotRow != i) {
        final temp = aug[i];
        aug[i] = aug[pivotRow];
        aug[pivotRow] = temp;
      }

      // Escalar fila pivote para que el pivote sea 1.0
      final double pivot = aug[i][i];
      for (int c = 0; c < cols; c++) {
        aug[i][c] /= pivot;
      }

      // Eliminar el resto de filas en la columna i
      for (int r = 0; r < n; r++) {
        if (r == i) continue;
        final double factor = aug[r][i];
        if (factor.abs() > 1e-14) {
          for (int c = 0; c < cols; c++) {
            aug[r][c] -= factor * aug[i][c];
          }
        }
      }
    }

    // Extraer la mitad derecha
    final List<List<double>> inv = List.generate(
      n,
      (r) => List.generate(n, (c) {
        final val = aug[r][n + c];
        return val.abs() < 1e-12 ? 0.0 : val;
      }),
    );

    return inv;
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
    return '[${m.map((row) => row.map((val) => formatDouble(val)).join(', ')).join('; ')}]';
  }
}
