import 'dart:math' as math;

enum TokenType {
  number,
  operator,
  unaryPlus,
  unaryMinus,
  function,
  constant,
  leftParen,
  rightParen,
}

class Token {
  final TokenType type;
  final dynamic value;
  final String raw;

  Token({required this.type, this.value, required this.raw});

  @override
  String toString() => 'Token(${type.name}, $value)';
}

class OperatorProperties {
  final int precedence;
  final bool isLeftAssociative;

  OperatorProperties(this.precedence, this.isLeftAssociative);
}

class MathParser {
  static final Map<String, OperatorProperties> _opProps = {
    '+': OperatorProperties(2, true),
    '-': OperatorProperties(2, true),
    '*': OperatorProperties(3, true),
    '/': OperatorProperties(3, true),
    '%': OperatorProperties(3, true),
    'UNARY_MINUS': OperatorProperties(5, false),
    'UNARY_PLUS': OperatorProperties(5, false),
    '^': OperatorProperties(6, false),
    '!': OperatorProperties(7, true),
  };

  /// Tokeniza la expresión en una lista de tokens.
  static List<Token> tokenize(String str) {
    final List<Token> tokens = [];
    int i = 0;
    // Quitar espacios
    str = str.replaceAll(RegExp(r'\s+'), '');

    final numRegex = RegExp(r'^\d+(\.\d+)?');
    final dotNumRegex = RegExp(r'^\.\d+');

    while (i < str.length) {
      final char = str[i];

      // Números con o sin decimal inicial
      if (char == '.' || RegExp(r'\d').hasMatch(char)) {
        final remaining = str.substring(i);
        var match = numRegex.firstMatch(remaining);
        if (match == null && char == '.') {
          match = dotNumRegex.firstMatch(remaining);
        }

        if (match != null) {
          final valStr = match.group(0)!;
          final value = double.parse(valStr.startsWith('.') ? '0$valStr' : valStr);
          tokens.add(Token(type: TokenType.number, value: value, raw: valStr));
          i += valStr.length;
          continue;
        }
      }

      // Paréntesis
      if (char == '(') {
        tokens.add(Token(type: TokenType.leftParen, value: '(', raw: '('));
        i++;
        continue;
      }
      if (char == ')') {
        tokens.add(Token(type: TokenType.rightParen, value: ')', raw: ')'));
        i++;
        continue;
      }

      // Operadores de un caracter
      if (RegExp(r'[\+\-\*\/\^\%\!]').hasMatch(char)) {
        tokens.add(Token(type: TokenType.operator, value: char, raw: char));
        i++;
        continue;
      }

      // Constante pi / π
      if (str.startsWith('pi', i) || str.startsWith('π', i)) {
        final len = str.startsWith('pi', i) ? 2 : 1;
        tokens.add(Token(type: TokenType.constant, value: 'pi', raw: str.substring(i, i + len)));
        i += len;
        continue;
      }

      // Constante e
      if (char == 'e') {
        tokens.add(Token(type: TokenType.constant, value: 'e', raw: 'e'));
        i++;
        continue;
      }

      // Funciones científicas
      var matchedFunc = false;
      final funcs = ['asin', 'acos', 'atan', 'sin', 'cos', 'tan', 'ln', 'log', 'sqrt'];
      for (final f in funcs) {
        if (str.startsWith(f, i)) {
          tokens.add(Token(type: TokenType.function, value: f, raw: f));
          i += f.length;
          matchedFunc = true;
          break;
        }
      }
      if (matchedFunc) continue;

      // Si hay algún carácter desconocido, lo ignoramos para evitar bucles infinitos
      i++;
    }

    return tokens;
  }

  /// Inserta operadores de multiplicación implícitos.
  /// Ej. 2pi -> 2 * pi, 2(3+4) -> 2 * (3+4)
  static List<Token> insertImplicitMultiplication(List<Token> tokens) {
    final List<Token> result = [];
    for (int i = 0; i < tokens.length; i++) {
      result.add(tokens[i]);
      if (i + 1 < tokens.length) {
        final curr = tokens[i];
        final next = tokens[i + 1];

        final isCurrTerm = curr.type == TokenType.number ||
            curr.type == TokenType.constant ||
            curr.type == TokenType.rightParen ||
            (curr.type == TokenType.operator && curr.value == '!');

        final isNextTerm = next.type == TokenType.number ||
            next.type == TokenType.constant ||
            next.type == TokenType.function ||
            next.type == TokenType.leftParen;

        if (isCurrTerm && isNextTerm) {
          result.add(Token(type: TokenType.operator, value: '*', raw: '*'));
        }
      }
    }
    return result;
  }

  /// Identifica operadores unarios (+ y - de signo)
  static List<Token> identifyUnaryOperators(List<Token> tokens) {
    final List<Token> result = [];
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.type == TokenType.operator && (token.value == '-' || token.value == '+')) {
        final prev = i > 0 ? tokens[i - 1] : null;
        // Es unario si está al principio, después de un paréntesis abierto, o después de otro operador binario
        final isUnary = prev == null ||
            prev.type == TokenType.leftParen ||
            (prev.type == TokenType.operator && prev.value != '!');

        if (isUnary) {
          final unaryType = token.value == '-' ? TokenType.unaryMinus : TokenType.unaryPlus;
          final val = token.value == '-' ? 'UNARY_MINUS' : 'UNARY_PLUS';
          result.add(Token(type: unaryType, value: val, raw: token.raw));
          continue;
        }
      }
      result.add(token);
    }
    return result;
  }

  /// Convierte de infijo a posfijo usando el algoritmo Shunting-Yard.
  static List<Token> infixToPostfix(List<Token> tokens) {
    final List<Token> outputQueue = [];
    final List<Token> operatorStack = [];

    for (final token in tokens) {
      if (token.type == TokenType.number || token.type == TokenType.constant) {
        outputQueue.add(token);
      } else if (token.type == TokenType.function) {
        operatorStack.add(token);
      } else if (token.type == TokenType.operator && token.value == '!') {
        // Factorial es postfix unario, actúa directamente sobre el operando anterior
        outputQueue.add(token);
      } else if (token.type == TokenType.operator ||
          token.type == TokenType.unaryMinus ||
          token.type == TokenType.unaryPlus) {
        
        final key1 = token.type == TokenType.operator ? token.value as String : token.value as String;
        
        while (operatorStack.isNotEmpty) {
          final top = operatorStack.last;
          if (top.type == TokenType.operator ||
              top.type == TokenType.unaryMinus ||
              top.type == TokenType.unaryPlus ||
              top.type == TokenType.function) {
            
            var shouldPop = false;
            if (top.type == TokenType.function) {
              shouldPop = true;
            } else {
              final key2 = top.type == TokenType.operator ? top.value as String : top.value as String;
              final p1 = _opProps[key1]!.precedence;
              final p2 = _opProps[key2]!.precedence;
              final assoc1 = _opProps[key1]!.isLeftAssociative;

              if (p2 > p1 || (p2 == p1 && assoc1)) {
                shouldPop = true;
              }
            }

            if (shouldPop) {
              outputQueue.add(operatorStack.removeLast());
            } else {
              break;
            }
          } else {
            break;
          }
        }
        operatorStack.add(token);
      } else if (token.type == TokenType.leftParen) {
        operatorStack.add(token);
      } else if (token.type == TokenType.rightParen) {
        var foundLeft = false;
        while (operatorStack.isNotEmpty) {
          if (operatorStack.last.type == TokenType.leftParen) {
            operatorStack.removeLast(); // sacar el '('
            foundLeft = true;
            break;
          }
          outputQueue.add(operatorStack.removeLast());
        }
        if (!foundLeft) {
          throw FormatException('Paréntesis impares');
        }
        // Si arriba del stack hay una función, sacarla a la cola
        if (operatorStack.isNotEmpty && operatorStack.last.type == TokenType.function) {
          outputQueue.add(operatorStack.removeLast());
        }
      }
    }

    while (operatorStack.isNotEmpty) {
      final op = operatorStack.removeLast();
      if (op.type == TokenType.leftParen || op.type == TokenType.rightParen) {
        throw FormatException('Paréntesis impares');
      }
      outputQueue.add(op);
    }

    return outputQueue;
  }

  /// Evalúa una lista en notación posfija (RPN) y devuelve el valor.
  static double evaluatePostfix(List<Token> postfix, String angleMode) {
    final List<double> stack = [];

    for (final token in postfix) {
      if (token.type == TokenType.number) {
        stack.add(token.value as double);
      } else if (token.type == TokenType.constant) {
        if (token.value == 'pi') {
          stack.add(math.pi);
        } else if (token.value == 'e') {
          stack.add(math.e);
        }
      } else if (token.type == TokenType.unaryMinus) {
        if (stack.isEmpty) throw FormatException('Sintaxis inválida');
        final val = stack.removeLast();
        stack.add(-val);
      } else if (token.type == TokenType.unaryPlus) {
        if (stack.isEmpty) throw FormatException('Sintaxis inválida');
        // No hace nada
      } else if (token.type == TokenType.operator) {
        if (token.value == '!') {
          if (stack.isEmpty) throw FormatException('Sintaxis inválida');
          final val = stack.removeLast();
          stack.add(mathFactorial(val));
        } else {
          if (stack.length < 2) throw FormatException('Sintaxis inválida');
          final b = stack.removeLast();
          final a = stack.removeLast();

          switch (token.value) {
            case '+': stack.add(a + b); break;
            case '-': stack.add(a - b); break;
            case '*': stack.add(a * b); break;
            case '/':
              if (b == 0) throw FormatException('División / 0');
              stack.add(a / b);
              break;
            case '^': stack.add(math.pow(a, b).toDouble()); break;
            case '%': stack.add(a % b); break;
            default: throw FormatException('Operador inválido');
          }
        }
      } else if (token.type == TokenType.function) {
        if (stack.isEmpty) throw FormatException('Sintaxis inválida');
        final val = stack.removeLast();

        switch (token.value) {
          case 'sin':
            final angle = angleMode == 'DEG' ? degToRad(val) : val;
            stack.add(math.sin(angle));
            break;
          case 'cos':
            final angle = angleMode == 'DEG' ? degToRad(val) : val;
            final res = math.cos(angle);
            stack.add(res.abs() < 1e-14 ? 0 : res);
            break;
          case 'tan':
            if (angleMode == 'DEG' && (val % 180).abs() == 90) {
              throw FormatException('Tan indefinida');
            }
            final angle = angleMode == 'DEG' ? degToRad(val) : val;
            final res = math.tan(angle);
            if (res.abs() > 1e14) throw FormatException('Tan indefinida');
            stack.add(res.abs() < 1e-14 ? 0 : res);
            break;
          case 'asin':
            if (val < -1 || val > 1) throw FormatException('Dom Err [-1, 1]');
            final res = math.asin(val);
            stack.add(angleMode == 'DEG' ? radToDeg(res) : res);
            break;
          case 'acos':
            if (val < -1 || val > 1) throw FormatException('Dom Err [-1, 1]');
            final res = math.acos(val);
            stack.add(angleMode == 'DEG' ? radToDeg(res) : res);
            break;
          case 'atan':
            final res = math.atan(val);
            stack.add(angleMode == 'DEG' ? radToDeg(res) : res);
            break;
          case 'ln':
            if (val <= 0) throw FormatException('Dom Err (>0)');
            stack.add(math.log(val));
            break;
          case 'log':
            if (val <= 0) throw FormatException('Dom Err (>0)');
            stack.add(math.log(val) / math.ln10);
            break;
          case 'sqrt':
            if (val < 0) throw FormatException('Dom Err (>=0)');
            stack.add(math.sqrt(val));
            break;
          default:
            throw FormatException('Función inválida');
        }
      }
    }

    if (stack.length != 1) {
      throw FormatException('Sintaxis inválida');
    }

    return stack.first;
  }

  static double degToRad(double deg) => deg * math.pi / 180;
  static double radToDeg(double rad) => rad * 180 / math.pi;

  static double mathFactorial(double n) {
    if (n < 0) throw FormatException('Factorial < 0');
    if (n % 1 != 0) throw FormatException('Fac no entero');
    if (n > 170) throw FormatException('Desbordamiento');
    if (n == 0 || n == 1) return 1;
    double res = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      res *= i;
    }
    return res;
  }

  /// Evalúa una expresión directamente desde una cadena de texto.
  static double eval(String expression, String angleMode) {
    final tokens = tokenize(expression);
    final implicit = insertImplicitMultiplication(tokens);
    final parsed = identifyUnaryOperators(implicit);
    final postfix = infixToPostfix(parsed);
    return evaluatePostfix(postfix, angleMode);
  }
}
