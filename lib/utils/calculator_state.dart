import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';
import 'math_parser.dart';
import 'matrix_ops.dart';

class CalculatorState extends ChangeNotifier {
  // ==========================================
  // 1. ESTADO DE CALCULADORA CIENTÍFICA
  // ==========================================
  String currentExpr = '';
  String currentNum = '';
  String expressionText = '';
  String inputText = '0';
  String angleMode = 'DEG';
  double memoryValue = 0.0;
  bool shouldResetScreen = false;
  double? lastResult;

  // ==========================================
  // 2. ESTADO DE MATRICES
  // ==========================================
  int matrixARows = 2;
  int matrixACols = 2;
  int matrixBRows = 2;
  int matrixBCols = 2;

  // Datos de matrices 2x2 (se inicializan en ceros)
  List<List<double>> matrixA = [
    [0.0, 0.0],
    [0.0, 0.0],
  ];
  List<List<double>> matrixB = [
    [0.0, 0.0],
    [0.0, 0.0],
  ];

  double scalarK = 2.0;
  List<List<double>>? matrixResult;
  double? scalarResult;
  String? matrixError;

  // ==========================================
  // 3. ESTADO DEL HISTORIAL
  // ==========================================
  List<HistoryItem> historyList = [];

  CalculatorState() {
    _loadHistoryFromPrefs();
  }

  // ==========================================
  // 4. FUNCIONALIDADES CIENTÍFICAS
  // ==========================================

  void toggleAngleMode() {
    angleMode = angleMode == 'DEG' ? 'RAD' : 'DEG';
    notifyListeners();
  }

  void handleClearAll() {
    currentExpr = '';
    currentNum = '';
    expressionText = '';
    inputText = '0';
    shouldResetScreen = false;
    notifyListeners();
  }

  void handleBackspace() {
    if (shouldResetScreen) {
      currentExpr = '';
      shouldResetScreen = false;
      _updateDisplayStrings();
      return;
    }

    // Borrar funciones completas como "sin(", "sqrt(", etc.
    final funcs = ['asin(', 'acos(', 'atan(', 'sin(', 'cos(', 'tan(', 'ln(', 'log(', 'sqrt('];
    bool deletedFunc = false;
    for (final f in funcs) {
      if (currentExpr.endsWith(f)) {
        currentExpr = currentExpr.substring(0, currentExpr.length - f.length);
        deletedFunc = true;
        break;
      }
    }

    if (!deletedFunc && currentExpr.isNotEmpty) {
      currentExpr = currentExpr.substring(0, currentExpr.length - 1);
    }

    // Sincronizar el número actual buscando el último bloque numérico
    final match = RegExp(r'[\d\.]*$').firstMatch(currentExpr);
    currentNum = match != null ? match.group(0) ?? '' : '';

    _updateDisplayStrings();
  }

  void handleValInput(String val) {
    if (shouldResetScreen) {
      final isOperator = RegExp(r'[\+\-\*\/\^\%]').hasMatch(val);
      if (isOperator && lastResult != null) {
        currentExpr = lastResult!.toString() + val;
        currentNum = '';
      } else {
        currentExpr = val;
        currentNum = val;
      }
      shouldResetScreen = false;
    } else {
      currentExpr += val;
      currentNum += val;
    }
    _updateDisplayStrings();
  }

  void handleActionInput(String action) {
    if (shouldResetScreen) {
      final isPostfix = ['fact', 'sqr', 'cube', 'recip'].contains(action);
      if (isPostfix && lastResult != null) {
        currentExpr = lastResult!.toString();
      } else {
        currentExpr = '';
      }
      currentNum = '';
      shouldResetScreen = false;
    }

    if (action == 'fact') {
      currentExpr += '!';
      currentNum = '';
    } else if (action == 'sqr') {
      currentExpr += '^2';
      currentNum = '';
    } else if (action == 'cube') {
      currentExpr += '^3';
      currentNum = '';
    } else if (action == 'recip') {
      currentExpr += '^-1';
      currentNum = '';
    } else {
      // Funciones trigonométricas / raíz
      currentExpr += '$action(';
      currentNum = '';
    }
    _updateDisplayStrings();
  }

  void handleToggleSign() {
    if (shouldResetScreen) {
      if (lastResult != null) {
        currentExpr = (-lastResult!).toString();
        currentNum = currentExpr;
        shouldResetScreen = false;
        _updateDisplayStrings();
      }
      return;
    }

    if (currentNum.isNotEmpty) {
      final len = currentNum.length;
      String negated = '';
      if (currentNum.startsWith('-')) {
        negated = currentNum.substring(1);
      } else {
        negated = '-$currentNum';
      }
      currentExpr = currentExpr.substring(0, currentExpr.length - len) + negated;
      currentNum = negated;
    } else {
      currentExpr += '-';
      currentNum = '-';
    }
    _updateDisplayStrings();
  }

  void handleDecimalPoint() {
    if (shouldResetScreen) {
      currentExpr = '0.';
      currentNum = '0.';
      shouldResetScreen = false;
      _updateDisplayStrings();
      return;
    }

    if (!currentNum.contains('.')) {
      if (currentNum.isEmpty || RegExp(r'[\+\-\*\/\^\(\%]$').hasMatch(currentExpr)) {
        currentExpr += '0.';
        currentNum = '0.';
      } else {
        currentExpr += '.';
        currentNum += '.';
      }
      _updateDisplayStrings();
    }
  }

  void evaluateScientific() {
    if (currentExpr.isEmpty) return;

    try {
      final double result = MathParser.eval(currentExpr, angleMode);
      final rawExpr = currentExpr;
      final formattedResult = MatrixOps.formatDouble(result);

      // Guardar en el historial
      _addHistoryItem(
        HistoryItem(
          type: 'sci',
          expression: '${_formatExpressionVisual(rawExpr)} =',
          result: formattedResult,
          numericResult: result,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      lastResult = result;
      currentExpr = result.toString();
      currentNum = result.toString();
      shouldResetScreen = true;

      expressionText = '${_formatExpressionVisual(rawExpr)} =';
      inputText = formattedResult;
    } catch (e) {
      inputText = e is FormatException ? e.message : 'Error';
      shouldResetScreen = true;
      lastResult = null;
    }
    notifyListeners();
  }

  // --- Operaciones de Memoria ---
  void memoryClear() {
    memoryValue = 0.0;
    notifyListeners();
  }

  void memoryRecall() {
    if (shouldResetScreen) {
      currentExpr = memoryValue.toString();
      currentNum = memoryValue.toString();
      shouldResetScreen = false;
    } else {
      currentExpr += memoryValue.toString();
      currentNum += memoryValue.toString();
    }
    _updateDisplayStrings();
  }

  void memoryAdd() {
    final double? currentVal = double.tryParse(inputText.replaceAll(',', ''));
    if (currentVal != null) {
      memoryValue += currentVal;
    }
    notifyListeners();
  }

  void memorySubtract() {
    final double? currentVal = double.tryParse(inputText.replaceAll(',', ''));
    if (currentVal != null) {
      memoryValue -= currentVal;
    }
    notifyListeners();
  }

  void memoryStore() {
    final double? currentVal = double.tryParse(inputText.replaceAll(',', ''));
    if (currentVal != null) {
      memoryValue = currentVal;
    }
    notifyListeners();
  }

  // Sincroniza displays visuales de la científica
  void _updateDisplayStrings() {
    expressionText = _formatExpressionVisual(currentExpr);
    inputText = currentNum.isEmpty ? '0' : _formatExpressionVisual(currentNum);
    notifyListeners();
  }

  String _formatExpressionVisual(String expr) {
    var display = expr;
    final replacements = [
      {'raw': 'asin', 'nice': 'sin⁻¹'},
      {'raw': 'acos', 'nice': 'cos⁻¹'},
      {'raw': 'atan', 'nice': 'tan⁻¹'},
      {'raw': 'sin', 'nice': 'sin'},
      {'raw': 'cos', 'nice': 'cos'},
      {'raw': 'tan', 'nice': 'tan'},
      {'raw': 'sqrt', 'nice': '√'},
      {'raw': 'ln', 'nice': 'ln'},
      {'raw': 'log', 'nice': 'log'},
      {'raw': 'pi', 'nice': 'π'},
      {'raw': '*', 'nice': ' × '},
      {'raw': '/', 'nice': ' ÷ '},
      {'raw': '+', 'nice': ' + '},
      {'raw': '-', 'nice': ' − '},
      {'raw': '^', 'nice': ' ^ '},
    ];

    for (final r in replacements) {
      display = display.replaceAll(r['raw']!, r['nice']!);
    }
    return display;
  }

  // ==========================================
  // 5. FUNCIONALIDADES DE MATRICES
  // ==========================================

  void updateMatrixADimensions(int rows, int cols) {
    matrixARows = rows;
    matrixACols = cols;

    // Generar nueva matriz preservando celdas anteriores si caben
    final List<List<double>> temp = List.generate(2, (_) => List.filled(2, 0.0));
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        if (r < matrixA.length && c < matrixA[r].length) {
          temp[r][c] = matrixA[r][c];
        }
      }
    }
    matrixA = temp;
    notifyListeners();
  }

  void updateMatrixBDimensions(int rows, int cols) {
    matrixBRows = rows;
    matrixBCols = cols;

    final List<List<double>> temp = List.generate(2, (_) => List.filled(2, 0.0));
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        if (r < matrixB.length && c < matrixB[r].length) {
          temp[r][c] = matrixB[r][c];
        }
      }
    }
    matrixB = temp;
    notifyListeners();
  }

  void setMatrixAValue(int r, int c, double val) {
    matrixA[r][c] = val;
  }

  void setMatrixBValue(int r, int c, double val) {
    matrixB[r][c] = val;
  }

  void updateScalarK(double val) {
    scalarK = val;
    notifyListeners();
  }

  List<List<double>> _getTrimmedMatrix(List<List<double>> full, int rMax, int cMax) {
    return List.generate(rMax, (r) => List.generate(cMax, (c) => full[r][c]));
  }

  void matrixAdd() {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    if (matrixARows != matrixBRows || matrixACols != matrixBCols) {
      matrixError = 'Error de dimensión: Las dimensiones deben ser idénticas. (A: ${matrixARows}x$matrixACols, B: ${matrixBRows}x$matrixBCols)';
      notifyListeners();
      return;
    }

    try {
      final matA = _getTrimmedMatrix(matrixA, matrixARows, matrixACols);
      final matB = _getTrimmedMatrix(matrixB, matrixBRows, matrixBCols);

      final result = MatrixOps.add(matA, matB);
      matrixResult = result;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: '${MatrixOps.formatMatrix(matA)} + ${MatrixOps.formatMatrix(matB)} =',
          result: MatrixOps.formatMatrix(result),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void matrixSubtract() {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    if (matrixARows != matrixBRows || matrixACols != matrixBCols) {
      matrixError = 'Error de dimensión: Las dimensiones deben ser idénticas. (A: ${matrixARows}x$matrixACols, B: ${matrixBRows}x$matrixBCols)';
      notifyListeners();
      return;
    }

    try {
      final matA = _getTrimmedMatrix(matrixA, matrixARows, matrixACols);
      final matB = _getTrimmedMatrix(matrixB, matrixBRows, matrixBCols);

      final result = MatrixOps.subtract(matA, matB);
      matrixResult = result;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: '${MatrixOps.formatMatrix(matA)} − ${MatrixOps.formatMatrix(matB)} =',
          result: MatrixOps.formatMatrix(result),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void matrixMultiply() {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    if (matrixACols != matrixBRows) {
      matrixError = 'Error de dimensión: Columnas de A ($matrixACols) deben coincidir con filas de B ($matrixBRows).';
      notifyListeners();
      return;
    }

    try {
      final matA = _getTrimmedMatrix(matrixA, matrixARows, matrixACols);
      final matB = _getTrimmedMatrix(matrixB, matrixBRows, matrixBCols);

      final result = MatrixOps.multiply(matA, matB);
      matrixResult = result;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: '${MatrixOps.formatMatrix(matA)} × ${MatrixOps.formatMatrix(matB)} =',
          result: MatrixOps.formatMatrix(result),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void matrixDeterminant(String name) {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    final targetName = name.toLowerCase();
    final rows = targetName == 'a' ? matrixARows : matrixBRows;
    final cols = targetName == 'a' ? matrixACols : matrixBCols;

    if (rows != cols) {
      matrixError = 'El determinante solo se puede calcular en matrices cuadradas.';
      notifyListeners();
      return;
    }

    try {
      final mat = _getTrimmedMatrix(
        targetName == 'a' ? matrixA : matrixB,
        rows,
        cols,
      );

      final det = MatrixOps.determinant(mat);
      scalarResult = det;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: 'det(${MatrixOps.formatMatrix(mat)}) =',
          result: MatrixOps.formatDouble(det),
          numericResult: det,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void matrixInverse(String name) {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    final targetName = name.toLowerCase();
    final rows = targetName == 'a' ? matrixARows : matrixBRows;
    final cols = targetName == 'a' ? matrixACols : matrixBCols;

    if (rows != cols) {
      matrixError = 'La inversa solo está definida para matrices cuadradas.';
      notifyListeners();
      return;
    }

    try {
      final mat = _getTrimmedMatrix(
        targetName == 'a' ? matrixA : matrixB,
        rows,
        cols,
      );

      final inv = MatrixOps.inverse(mat);
      matrixResult = inv;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: '${MatrixOps.formatMatrix(mat)}⁻¹ =',
          result: MatrixOps.formatMatrix(inv),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void matrixTranspose(String name) {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    final targetName = name.toLowerCase();
    final rows = targetName == 'a' ? matrixARows : matrixBRows;
    final cols = targetName == 'a' ? matrixACols : matrixBCols;

    try {
      final mat = _getTrimmedMatrix(
        targetName == 'a' ? matrixA : matrixB,
        rows,
        cols,
      );

      final trans = MatrixOps.transpose(mat);
      matrixResult = trans;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: '${MatrixOps.formatMatrix(mat)}ᵀ =',
          result: MatrixOps.formatMatrix(trans),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void matrixScalarMultiply(String name) {
    matrixError = null;
    matrixResult = null;
    scalarResult = null;

    final targetName = name.toLowerCase();
    final rows = targetName == 'a' ? matrixARows : matrixBRows;
    final cols = targetName == 'a' ? matrixACols : matrixBCols;

    try {
      final mat = _getTrimmedMatrix(
        targetName == 'a' ? matrixA : matrixB,
        rows,
        cols,
      );

      final res = MatrixOps.scalarMultiply(mat, scalarK);
      matrixResult = res;

      _addHistoryItem(
        HistoryItem(
          type: 'matrix',
          expression: '${MatrixOps.formatDouble(scalarK)} · ${MatrixOps.formatMatrix(mat)} =',
          result: MatrixOps.formatMatrix(res),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      matrixError = e.toString();
    }
    notifyListeners();
  }

  void importKFromCalculator() {
    final double? val = double.tryParse(inputText.replaceAll(',', ''));
    if (val != null) {
      scalarK = val;
      notifyListeners();
    }
  }

  void swapMatrices() {
    // Intercambiar dimensiones
    final tempRows = matrixARows;
    final tempCols = matrixACols;
    matrixARows = matrixBRows;
    matrixACols = matrixBCols;
    matrixBRows = tempRows;
    matrixBCols = tempCols;

    // Intercambiar datos
    final tempA = matrixA;
    matrixA = matrixB;
    matrixB = tempA;

    notifyListeners();
  }

  void clearMatrices() {
    matrixA = [
      [0.0, 0.0],
      [0.0, 0.0]
    ];
    matrixB = [
      [0.0, 0.0],
      [0.0, 0.0]
    ];
    matrixResult = null;
    scalarResult = null;
    matrixError = null;
    notifyListeners();
  }

  void copyResultToA() {
    if (matrixResult == null) return;
    final res = matrixResult!;
    matrixARows = res.length;
    matrixACols = res[0].length;

    matrixA = [
      [0.0, 0.0],
      [0.0, 0.0]
    ];
    for (int r = 0; r < matrixARows; r++) {
      for (int c = 0; c < matrixACols; c++) {
        matrixA[r][c] = res[r][c];
      }
    }
    notifyListeners();
  }

  void copyResultToB() {
    if (matrixResult == null) return;
    final res = matrixResult!;
    matrixBRows = res.length;
    matrixBCols = res[0].length;

    matrixB = [
      [0.0, 0.0],
      [0.0, 0.0]
    ];
    for (int r = 0; r < matrixBRows; r++) {
      for (int c = 0; c < matrixBCols; c++) {
        matrixB[r][c] = res[r][c];
      }
    }
    notifyListeners();
  }

  void sendResultToCalculator() {
    double? targetVal;
    if (scalarResult != null) {
      targetVal = scalarResult;
    } else if (matrixResult != null) {
      targetVal = matrixResult![0][0];
    }

    if (targetVal != null) {
      currentExpr = targetVal.toString();
      currentNum = targetVal.toString();
      shouldResetScreen = false;
      _updateDisplayStrings();
    }
  }

  // ==========================================
  // 6. CONTROL DEL HISTORIAL (PREFS)
  // ==========================================

  Future<void> _loadHistoryFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString('sci_mat_calc_history');
      if (raw != null) {
        final List<dynamic> decoded = json.decode(raw);
        historyList = decoded.map((map) => HistoryItem.fromMap(map)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Ignorar errores silenciosamente
    }
  }

  Future<void> _saveHistoryToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> maps = historyList.map((item) => item.toMap()).toList();
      await prefs.setString('sci_mat_calc_history', json.encode(maps));
    } catch (e) {
      // Ignorar
    }
  }

  void _addHistoryItem(HistoryItem item) {
    historyList.insert(0, item);
    if (historyList.length > 30) {
      historyList.removeLast();
    }
    _saveHistoryToPrefs();
    notifyListeners();
  }

  void clearHistory() {
    historyList.clear();
    _saveHistoryToPrefs();
    notifyListeners();
  }

  void loadHistoryItem(HistoryItem item) {
    if (item.type == 'sci') {
      if (item.numericResult != null) {
        currentExpr = item.numericResult!.toString();
        currentNum = item.numericResult!.toString();
        shouldResetScreen = true;
        _updateDisplayStrings();
      }
    } else {
      if (item.numericResult != null) {
        scalarK = item.numericResult!;
        notifyListeners();
      }
    }
  }
}
