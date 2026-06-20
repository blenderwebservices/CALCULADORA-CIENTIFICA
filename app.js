/**
 * CALCULADORA CIENTÍFICA & MATRICIAL - LÓGICA DE LA APLICACIÓN
 * Implementación de Tokenizer, Shunting-Yard Parser y Operaciones Matriciales Avanzadas.
 */

// ==========================================================================
// 1. SELECTORES DE ELEMENTOS DEL DOM
// ==========================================================================

// Pestañas y Navegación Móvil
const tabButtons = document.querySelectorAll('.tab-btn');
const panels = document.querySelectorAll('.dashboard-panel');

// Pantalla y Estados de la Calculadora Científica
const expressionDisplay = document.getElementById('expression-display');
const inputDisplay = document.getElementById('input-display');
const angleModeIndicator = document.getElementById('angle-mode-indicator');
const memoryIndicator = document.getElementById('memory-indicator');

// Botones y Utilidades de la Calculadora
const btnToggleAngle = document.getElementById('btn-toggle-angle');
const sciKeypad = document.querySelector('.sci-keypad');
const btnClear = document.getElementById('btn-clear');
const btnBackspace = document.getElementById('btn-backspace');
const btnEquals = document.getElementById('btn-equals');
const btnToggleSign = document.getElementById('btn-toggle-sign');
const btnDecimal = document.getElementById('btn-decimal');

// Botones de Memoria
const btnMC = document.getElementById('btn-mc');
const btnMR = document.getElementById('btn-mr');
const btnMPlus = document.getElementById('btn-mplus');
const btnMMinus = document.getElementById('btn-mminus');
const btnMS = document.getElementById('btn-ms');

// Panel Matricial - Selectores de Dimensiones y Contenedores de Rejilla
const selectARows = document.getElementById('matrix-a-rows');
const selectACols = document.getElementById('matrix-a-cols');
const selectBRows = document.getElementById('matrix-b-rows');
const selectBCols = document.getElementById('matrix-b-cols');
const gridMatrixA = document.getElementById('matrix-a-grid');
const gridMatrixB = document.getElementById('matrix-b-grid');

// Botones de Operación Matricial
const btnSwapMatrices = document.getElementById('btn-swap-matrices');
const btnClearMatrices = document.getElementById('btn-clear-matrices');
const btnMatAdd = document.getElementById('btn-mat-add');
const btnMatSub = document.getElementById('btn-mat-sub');
const btnMatMul = document.getElementById('btn-mat-mul');
const btnMatDetA = document.getElementById('btn-mat-det-a');
const btnMatDetB = document.getElementById('btn-mat-det-b');
const btnMatInvA = document.getElementById('btn-mat-inv-a');
const btnMatInvB = document.getElementById('btn-mat-inv-b');
const btnMatTransA = document.getElementById('btn-mat-trans-a');
const btnMatTransB = document.getElementById('btn-mat-trans-b');

// Multiplicación Escalar
const inputScalarK = document.getElementById('scalar-k');
const btnImportK = document.getElementById('btn-import-k');
const btnMatScalarA = document.getElementById('btn-mat-scalar-a');
const btnMatScalarB = document.getElementById('btn-mat-scalar-b');

// Resultado Matricial y Acciones
const resultContainer = document.getElementById('matrix-result-container');
const resultBox = document.getElementById('matrix-result-box');
const resultActions = document.getElementById('matrix-result-actions');
const btnCopyToA = document.getElementById('btn-copy-to-a');
const btnCopyToB = document.getElementById('btn-copy-to-b');
const btnSendToCalc = document.getElementById('btn-send-to-calc');

// Panel de Historial
const historyList = document.getElementById('history-list');
const btnClearHistory = document.getElementById('btn-clear-history');
const historyEmptyMessage = document.getElementById('history-empty');

// ==========================================================================
// 2. ESTADO GLOBAL DE LA APLICACIÓN
// ==========================================================================
let currentExpr = '';        // Expresión matemática en bruto (ej. 2*sin(pi/6))
let currentNum = '';         // Número que se está escribiendo en el momento
let shouldResetScreen = false; // Indica si al pulsar una tecla se debe borrar la pantalla
let lastResult = null;       // Guarda el último resultado calculado exitosamente
let angleMode = 'DEG';       // Modo de ángulo por defecto: DEG (Grados) o RAD (Radianes)
let memoryValue = 0;         // Almacén de memoria (M)

// Dimensiones de Matrices
let matrixARows = 2;
let matrixACols = 2;
let matrixBRows = 2;
let matrixBCols = 2;

// Resultados Matriciales Temporales
let resultMatrixData = null;  // Guarda la matriz calculada en 2D
let resultScalarData = null;  // Guarda un resultado escalar (ej. determinante)

// Historial
let history = [];

// Símbolos de visualización premium para la pantalla superior
const opSymbolsMap = {
  '*': ' × ',
  '/': ' ÷ ',
  '+': ' + ',
  '-': ' − ',
  '^': ' ^ ',
  'pi': 'π',
  'asin': 'sin⁻¹',
  'acos': 'cos⁻¹',
  'atan': 'tan⁻¹',
  'sqrt': '√'
};

// ==========================================================================
// 3. INICIALIZACIÓN Y EVENTOS DE CARGA
// ==========================================================================
document.addEventListener('DOMContentLoaded', () => {
  // Configuración de Pestañas Móviles
  setupMobileTabs();

  // Configuración de Matrices
  initMatrices();

  // Escuchadores de Eventos del Teclado Científico
  setupScientificListeners();

  // Escuchadores de Eventos del Panel Matricial
  setupMatrixListeners();

  // Teclado Físico
  setupPhysicalKeyboard();

  // Cargar Historial
  loadHistory();
  updateDisplay();
});

// Cambiar entre Pestañas en Dispositivos Móviles
function setupMobileTabs() {
  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const tabName = btn.dataset.tab;
      
      // Activar botón de pestaña
      tabButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      // Mostrar panel correspondiente
      panels.forEach(panel => {
        panel.classList.remove('active-tab');
        if (panel.id === `panel-${tabName}`) {
          panel.classList.add('active-tab');
        }
      });
    });
  });
}

// Agregar Animación Visual al Pulsar Botón
function animateButton(btn) {
  if (!btn) return;
  btn.classList.add('key-press-animation');
  btn.addEventListener('animationend', () => {
    btn.classList.remove('key-press-animation');
  }, { once: true });
}

// ==========================================================================
// 4. MOTOR DE PARSEO MATEMÁTICO (LEXER + SHUNTING-YARD)
// ==========================================================================

/**
 * Convierte un string matemático a una lista de tokens.
 */
function tokenize(str) {
  const tokens = [];
  let i = 0;
  
  // Limpiar espacios en blanco
  str = str.replace(/\s+/g, '');
  
  while (i < str.length) {
    const char = str[i];
    
    // Números enteros o decimales (ej. 3.14, .5)
    if (/\d/.test(char) || (char === '.' && i + 1 < str.length && /\d/.test(str[i+1]))) {
      let numStr = '';
      if (char === '.') {
        numStr = '0.';
        i++;
      }
      while (i < str.length && (/\d/.test(str[i]) || str[i] === '.')) {
        numStr += str[i];
        i++;
      }
      tokens.push({ type: 'NUMBER', value: parseFloat(numStr), raw: numStr });
      continue;
    }
    
    // Paréntesis
    if (char === '(' || char === ')') {
      tokens.push({ type: char, value: char });
      i++;
      continue;
    }
    
    // Operadores
    if (/[\+\-\*\/\^\%\!]/.test(char)) {
      tokens.push({ type: 'OPERATOR', value: char });
      i++;
      continue;
    }
    
    // Constantes (pi, e)
    if (str.startsWith('pi', i) || str.startsWith('π', i)) {
      tokens.push({ type: 'CONSTANT', value: 'pi' });
      i += (str.startsWith('pi', i) ? 2 : 1);
      continue;
    }
    if (char === 'e') {
      tokens.push({ type: 'CONSTANT', value: 'e' });
      i++;
      continue;
    }

    // Funciones científicas (reconocimiento de prefijos)
    let matchedFunc = null;
    const funcs = ['asin', 'acos', 'atan', 'sin', 'cos', 'tan', 'ln', 'log', 'sqrt'];
    for (const f of funcs) {
      if (str.startsWith(f, i)) {
        matchedFunc = f;
        tokens.push({ type: 'FUNCTION', value: f });
        i += f.length;
        break;
      }
    }
    if (matchedFunc) continue;
    
    // Si hay algún carácter desconocido, lo saltamos silenciosamente para evitar bucles infinitos
    i++;
  }
  
  return tokens;
}

/**
 * Inserta el operador de multiplicación implícita '*' donde corresponda.
 * Ej. 2pi -> 2 * pi, 2(3+4) -> 2 * (3+4), (2+3)(4+5) -> (2+3) * (4+5)
 */
function insertImplicitMultiplication(tokens) {
  const result = [];
  for (let i = 0; i < tokens.length; i++) {
    result.push(tokens[i]);
    if (i + 1 < tokens.length) {
      const curr = tokens[i];
      const next = tokens[i + 1];
      
      const isCurrTerm = curr.type === 'NUMBER' || curr.type === 'CONSTANT' || curr.type === ')' || (curr.type === 'OPERATOR' && curr.value === '!');
      const isNextTerm = next.type === 'NUMBER' || next.type === 'CONSTANT' || next.type === 'FUNCTION' || next.type === '(';
      
      if (isCurrTerm && isNextTerm) {
        result.push({ type: 'OPERATOR', value: '*' });
      }
    }
  }
  return result;
}

/**
 * Identifica los operadores unarios (+ / - de signo) y los diferencia de los binarios.
 */
function identifyUnaryOperators(tokens) {
  const result = [];
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (token.type === 'OPERATOR' && (token.value === '-' || token.value === '+')) {
      const prev = i > 0 ? tokens[i - 1] : null;
      // Es unario si está al principio, después de un paréntesis abierto, o después de otro operador binario
      const isUnary = !prev || prev.type === '(' || (prev.type === 'OPERATOR' && prev.value !== '!');
      if (isUnary) {
        token.type = token.value === '-' ? 'UNARY_MINUS' : 'UNARY_PLUS';
      }
    }
    result.push(token);
  }
  return result;
}

// Jerarquía y propiedades de operadores
const OP_PROPERTIES = {
  '+': { precedence: 2, associativity: 'LEFT' },
  '-': { precedence: 2, associativity: 'LEFT' },
  '*': { precedence: 3, associativity: 'LEFT' },
  '/': { precedence: 3, associativity: 'LEFT' },
  '%': { precedence: 3, associativity: 'LEFT' },
  'UNARY_MINUS': { precedence: 5, associativity: 'RIGHT' },
  'UNARY_PLUS': { precedence: 5, associativity: 'RIGHT' },
  '^': { precedence: 6, associativity: 'RIGHT' },
  '!': { precedence: 7, associativity: 'LEFT' }
};

/**
 * Algoritmo Shunting-Yard para convertir de notación Infija a Postfija (RPN).
 */
function infixToPostfix(tokens) {
  const outputQueue = [];
  const operatorStack = [];
  
  for (const token of tokens) {
    if (token.type === 'NUMBER' || token.type === 'CONSTANT') {
      outputQueue.push(token);
    } else if (token.type === 'FUNCTION') {
      operatorStack.push(token);
    } else if (token.value === '!') {
      // El factorial es un operador postfix unario, lo mandamos directo a la cola para actuar sobre el último operando
      outputQueue.push(token);
    } else if (token.type === 'OPERATOR' || token.type === 'UNARY_MINUS' || token.type === 'UNARY_PLUS') {
      const o1 = token;
      let top = operatorStack[operatorStack.length - 1];
      
      while (top && (top.type === 'OPERATOR' || top.type === 'UNARY_MINUS' || top.type === 'UNARY_PLUS' || top.type === 'FUNCTION')) {
        let shouldPop = false;
        if (top.type === 'FUNCTION') {
          shouldPop = true;
        } else {
          const p1 = OP_PROPERTIES[o1.value || o1.type].precedence;
          const p2 = OP_PROPERTIES[top.value || top.type].precedence;
          const assoc1 = OP_PROPERTIES[o1.value || o1.type].associativity;
          
          if (p2 > p1 || (p2 === p1 && assoc1 === 'LEFT')) {
            shouldPop = true;
          }
        }
        
        if (shouldPop) {
          outputQueue.push(operatorStack.pop());
          top = operatorStack[operatorStack.length - 1];
        } else {
          break;
        }
      }
      operatorStack.push(o1);
    } else if (token.type === '(') {
      operatorStack.push(token);
    } else if (token.type === ')') {
      let top = operatorStack[operatorStack.length - 1];
      while (top && top.type !== '(') {
        outputQueue.push(operatorStack.pop());
        top = operatorStack[operatorStack.length - 1];
      }
      if (!top) {
        throw new Error('Paréntesis impares');
      }
      operatorStack.pop(); // Sacar el '('
      
      // Si arriba del stack hay una función, va a la cola de salida
      const nextTop = operatorStack[operatorStack.length - 1];
      if (nextTop && nextTop.type === 'FUNCTION') {
        outputQueue.push(operatorStack.pop());
      }
    }
  }
  
  while (operatorStack.length > 0) {
    const op = operatorStack.pop();
    if (op.type === '(' || op.type === ')') {
      throw new Error('Paréntesis impares');
    }
    outputQueue.push(op);
  }
  
  return outputQueue;
}

/**
 * Evalúa una expresión en notación Postfija (RPN) y devuelve el resultado escalar.
 */
function evaluatePostfix(postfix, mode) {
  const stack = [];
  
  for (const token of postfix) {
    if (token.type === 'NUMBER') {
      stack.push(token.value);
    } else if (token.type === 'CONSTANT') {
      if (token.value === 'pi') {
        stack.push(Math.PI);
      } else if (token.value === 'e') {
        stack.push(Math.E);
      }
    } else if (token.type === 'UNARY_MINUS') {
      if (stack.length < 1) throw new Error('Sintaxis inválida');
      const val = stack.pop();
      stack.push(-val);
    } else if (token.type === 'UNARY_PLUS') {
      if (stack.length < 1) throw new Error('Sintaxis inválida');
      // No hace nada
    } else if (token.type === 'OPERATOR') {
      if (token.value === '!') {
        if (stack.length < 1) throw new Error('Sintaxis inválida');
        const val = stack.pop();
        stack.push(mathFactorial(val));
      } else {
        if (stack.length < 2) throw new Error('Sintaxis inválida');
        const b = stack.pop();
        const a = stack.pop();
        
        switch (token.value) {
          case '+': stack.push(a + b); break;
          case '-': stack.push(a - b); break;
          case '*': stack.push(a * b); break;
          case '/': 
            if (b === 0) throw new Error('División / 0');
            stack.push(a / b); 
            break;
          case '^': stack.push(Math.pow(a, b)); break;
          case '%': stack.push(a % b); break;
          default: throw new Error('Operador inválido');
        }
      }
    } else if (token.type === 'FUNCTION') {
      if (stack.length < 1) throw new Error('Sintaxis inválida');
      const val = stack.pop();
      
      switch (token.value) {
        case 'sin':
          stack.push(Math.sin(mode === 'DEG' ? degToRad(val) : val));
          break;
        case 'cos':
          let cVal = Math.cos(mode === 'DEG' ? degToRad(val) : val);
          stack.push(Math.abs(cVal) < 1e-14 ? 0 : cVal); // Corregir imprecisión flotante (ej. cos(90) = 0)
          break;
        case 'tan':
          if (mode === 'DEG' && Math.abs(val % 180) === 90) {
            throw new Error('Tan indefinida');
          }
          let tVal = Math.tan(mode === 'DEG' ? degToRad(val) : val);
          if (Math.abs(tVal) > 1e14) throw new Error('Tan indefinida');
          stack.push(Math.abs(tVal) < 1e-14 ? 0 : tVal);
          break;
        case 'asin':
          if (val < -1 || val > 1) throw new Error('Dom Err [-1, 1]');
          let asinRad = Math.asin(val);
          stack.push(mode === 'DEG' ? radToDeg(asinRad) : asinRad);
          break;
        case 'acos':
          if (val < -1 || val > 1) throw new Error('Dom Err [-1, 1]');
          let acosRad = Math.acos(val);
          stack.push(mode === 'DEG' ? radToDeg(acosRad) : acosRad);
          break;
        case 'atan':
          let atanRad = Math.atan(val);
          stack.push(mode === 'DEG' ? radToDeg(atanRad) : atanRad);
          break;
        case 'ln':
          if (val <= 0) throw new Error('Dom Err (>0)');
          stack.push(Math.log(val));
          break;
        case 'log':
          if (val <= 0) throw new Error('Dom Err (>0)');
          stack.push(Math.log10(val));
          break;
        case 'sqrt':
          if (val < 0) throw new Error('Dom Err (>=0)');
          stack.push(Math.sqrt(val));
          break;
        default:
          throw new Error('Función inválida');
      }
    }
  }
  
  if (stack.length !== 1) {
    throw new Error('Sintaxis inválida');
  }
  
  return stack[0];
}

// Utilidades trigonométricas y especiales
function degToRad(deg) { return deg * Math.PI / 180; }
function radToDeg(rad) { return rad * 180 / Math.PI; }

function mathFactorial(n) {
  if (n < 0) throw new Error('Factorial < 0');
  if (!Number.isInteger(n)) throw new Error('Fac no entero');
  if (n > 170) throw new Error('Desbordamiento');
  if (n === 0 || n === 1) return 1;
  let res = 1;
  for (let i = 2; i <= n; i++) res *= i;
  return res;
}

// ==========================================================================
// 5. MANEJO DE LA CALCULADORA CIENTÍFICA (INTERFAZ Y FLUJO)
// ==========================================================================

// Formatear la fórmula cruda para mostrarla amigablemente al usuario
function formatExpression(expr) {
  let display = expr;
  // Reemplazar de forma ordenada para evitar pisar sub-cadenas
  // Primero ordenamos los reemplazos de más largo a más corto
  const replacements = [
    { raw: 'asin', nice: 'sin⁻¹' },
    { raw: 'acos', nice: 'cos⁻¹' },
    { raw: 'atan', nice: 'tan⁻¹' },
    { raw: 'sin', nice: 'sin' },
    { raw: 'cos', nice: 'cos' },
    { raw: 'tan', nice: 'tan' },
    { raw: 'sqrt', nice: '√' },
    { raw: 'ln', nice: 'ln' },
    { raw: 'log', nice: 'log' },
    { raw: 'pi', nice: 'π' },
    { raw: '*', nice: ' × ' },
    { raw: '/', nice: ' ÷ ' },
    { raw: '+', nice: ' + ' },
    { raw: '-', nice: ' − ' },
    { raw: '^', nice: ' ^ ' }
  ];

  for (const rep of replacements) {
    // Escapar operadores regex si es necesario
    const escaped = rep.raw.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
    const regex = new RegExp(escaped, 'g');
    display = display.replace(regex, rep.nice);
  }
  return display;
}

// Formatear números en pantalla (miles, decimales y notación científica)
function formatNumber(num) {
  if (num === null || isNaN(num)) return '0';
  if (!isFinite(num)) return 'Error';
  
  // Si es muy grande o muy pequeño, usar notación científica
  if (Math.abs(num) > 1e12 || (Math.abs(num) < 1e-6 && num !== 0)) {
    return num.toExponential(6);
  }
  
  // Limitar precisión decimal para evitar basura de coma flotante en JS
  const rounded = parseFloat(num.toFixed(10));
  const parts = rounded.toString().split('.');
  const intPart = parts[0];
  const decPart = parts.length > 1 ? '.' + parts[1] : '';

  // Añadir separador de miles local
  const formatter = new Intl.NumberFormat('es-MX', { useGrouping: true });
  let formattedInt = formatter.format(parseFloat(intPart));
  
  // Si era -0
  if (num === 0 && 1/num === -Infinity) {
    formattedInt = '-' + formattedInt;
  }
  if (intPart === '-0') {
    formattedInt = '-0';
  }

  return formattedInt + decPart;
}

// Actualizar las dos pantallas
function updateDisplay() {
  expressionDisplay.textContent = formatExpression(currentExpr);
  inputDisplay.textContent = currentNum === '' ? '0' : formatExpression(currentNum);
  
  // Scroll automático hacia la derecha si el contenido desborda
  expressionDisplay.scrollLeft = expressionDisplay.scrollWidth;
  inputDisplay.parentElement.scrollLeft = inputDisplay.parentElement.scrollWidth;
}

// Manejar entradas de botones numéricos / constantes / paréntesis básicos
function handleValInput(val) {
  if (shouldResetScreen) {
    // Si es un operador y tenemos un resultado previo, encadenamos la operación
    const isOperator = /[\+\-\*\/\^\%]/.test(val);
    if (isOperator && lastResult !== null) {
      currentExpr = lastResult.toString() + val;
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
  updateDisplay();
}

// Manejar entradas de funciones científicas (ej. sin, cos, ln)
function handleActionInput(action) {
  if (shouldResetScreen) {
    const isPostfix = ['fact', 'sqr', 'cube', 'recip'].includes(action);
    if (isPostfix && lastResult !== null) {
      currentExpr = lastResult.toString();
    } else {
      currentExpr = '';
    }
    currentNum = '';
    shouldResetScreen = false;
  }

  if (action === 'fact') {
    currentExpr += '!';
    currentNum = '';
  } else if (action === 'sqr') {
    currentExpr += '^2';
    currentNum = '';
  } else if (action === 'cube') {
    currentExpr += '^3';
    currentNum = '';
  } else if (action === 'recip') {
    currentExpr += '^-1';
    currentNum = '';
  } else {
    // Funciones trigonométricas, logarítmicas o raíz
    currentExpr += action + '(';
    currentNum = '';
  }
  updateDisplay();
}

// Manejar borrado completo (AC)
function handleClearAll() {
  currentExpr = '';
  currentNum = '';
  shouldResetScreen = false;
  updateDisplay();
}

// Manejar retroceso (Backspace)
function handleBackspaceChar() {
  if (shouldResetScreen) {
    currentExpr = '';
    shouldResetScreen = false;
    updateDisplay();
    return;
  }

  // Si termina con una función como 'sin(', 'sqrt(', etc., borrar toda la palabra
  const funcs = ['asin(', 'acos(', 'atan(', 'sin(', 'cos(', 'tan(', 'ln(', 'log(', 'sqrt('];
  let deletedFunc = false;
  for (const f of funcs) {
    if (currentExpr.endsWith(f)) {
      currentExpr = currentExpr.slice(0, -f.length);
      deletedFunc = true;
      break;
    }
  }

  if (!deletedFunc && currentExpr.length > 0) {
    currentExpr = currentExpr.slice(0, -1);
  }

  // Sincronizar el número actual
  // Buscamos el último grupo de caracteres numéricos
  const match = currentExpr.match(/[\d\.]*$/);
  currentNum = match ? match[0] : '';
  
  updateDisplay();
}

// Alternar signo ± del número activo
function handleToggleSignValue() {
  if (shouldResetScreen) {
    // Si acabamos de calcular, negamos el último resultado
    if (lastResult !== null) {
      currentExpr = (-lastResult).toString();
      currentNum = currentExpr;
      shouldResetScreen = false;
      updateDisplay();
    }
    return;
  }

  if (currentNum !== '') {
    // Tocar el signo en currentExpr reemplazando el último número
    const len = currentNum.length;
    let negated = '';
    if (currentNum.startsWith('-')) {
      negated = currentNum.slice(1);
    } else {
      negated = '-' + currentNum;
    }
    currentExpr = currentExpr.slice(0, -len) + negated;
    currentNum = negated;
  } else {
    // Si no hay número activo, ponemos '-' como inicio de número unario
    currentExpr += '-';
    currentNum = '-';
  }
  updateDisplay();
}

// Agregar punto decimal
function handleDecimalPoint() {
  if (shouldResetScreen) {
    currentExpr = '0.';
    currentNum = '0.';
    shouldResetScreen = false;
    updateDisplay();
    return;
  }

  if (!currentNum.includes('.')) {
    if (currentNum === '' || /[\+\-\*\/\^\(\%]$/.test(currentExpr)) {
      currentExpr += '0.';
      currentNum = '0.';
    } else {
      currentExpr += '.';
      currentNum += '.';
    }
    updateDisplay();
  }
}

// Evaluar la Expresión Científica Activa
function evaluateScientific() {
  if (currentExpr === '') return;
  
  try {
    const tokens = tokenize(currentExpr);
    const implicitTokens = insertImplicitMultiplication(tokens);
    const parsedTokens = identifyUnaryOperators(implicitTokens);
    const postfix = infixToPostfix(parsedTokens);
    const result = evaluatePostfix(postfix, angleMode);
    
    // Guardar en el historial
    const rawExpr = currentExpr;
    const formattedResult = formatNumber(result);
    
    addHistoryItem('sci', formatExpression(rawExpr) + ' =', formattedResult, result);

    // Actualizar estados
    lastResult = result;
    currentExpr = result.toString();
    currentNum = result.toString();
    shouldResetScreen = true;
    
    // Mostrar en pantalla
    expressionDisplay.textContent = formatExpression(rawExpr) + ' =';
    inputDisplay.textContent = formattedResult;
    
  } catch (error) {
    inputDisplay.textContent = error.message || 'Error';
    shouldResetScreen = true;
    lastResult = null;
  }
}

// Configurar los escuchadores del Keypad en pantalla
function setupScientificListeners() {
  // Toggle DEG / RAD
  btnToggleAngle.addEventListener('click', () => {
    angleMode = angleMode === 'DEG' ? 'RAD' : 'DEG';
    angleModeIndicator.textContent = angleMode;
  });

  // Evento de clicks en botones
  sciKeypad.addEventListener('click', (e) => {
    const btn = e.target.closest('.btn');
    if (!btn) return;
    
    animateButton(btn);

    const val = btn.dataset.val;
    const action = btn.dataset.action;

    if (val !== undefined) {
      handleValInput(val);
    } else if (action !== undefined) {
      handleActionInput(action);
    }
  });

  // Limpiar todo (AC)
  btnClear.addEventListener('click', () => {
    animateButton(btnClear);
    handleClearAll();
  });

  // Borrar carácter (Backspace)
  btnBackspace.addEventListener('click', () => {
    animateButton(btnBackspace);
    handleBackspaceChar();
  });

  // Signo ±
  btnToggleSign.addEventListener('click', () => {
    animateButton(btnToggleSign);
    handleToggleSignValue();
  });

  // Punto decimal
  btnDecimal.addEventListener('click', () => {
    animateButton(btnDecimal);
    handleDecimalPoint();
  });

  // Evaluar (=)
  btnEquals.addEventListener('click', () => {
    animateButton(btnEquals);
    evaluateScientific();
  });

  // --- CONTROLES DE MEMORIA ---
  btnMC.addEventListener('click', () => {
    animateButton(btnMC);
    memoryValue = 0;
    memoryIndicator.classList.remove('active');
  });

  btnMR.addEventListener('click', () => {
    animateButton(btnMR);
    if (shouldResetScreen) {
      currentExpr = memoryValue.toString();
      currentNum = memoryValue.toString();
      shouldResetScreen = false;
    } else {
      currentExpr += memoryValue.toString();
      currentNum += memoryValue.toString();
    }
    updateDisplay();
  });

  btnMPlus.addEventListener('click', () => {
    animateButton(btnMPlus);
    const val = parseFloat(inputDisplay.textContent.replace(/,/g, ''));
    if (!isNaN(val)) {
      memoryValue += val;
      memoryIndicator.classList.add('active');
    }
  });

  btnMMinus.addEventListener('click', () => {
    animateButton(btnMMinus);
    const val = parseFloat(inputDisplay.textContent.replace(/,/g, ''));
    if (!isNaN(val)) {
      memoryValue -= val;
      memoryIndicator.classList.add('active');
    }
  });

  btnMS.addEventListener('click', () => {
    animateButton(btnMS);
    const val = parseFloat(inputDisplay.textContent.replace(/,/g, ''));
    if (!isNaN(val)) {
      memoryValue = val;
      if (memoryValue !== 0) {
        memoryIndicator.classList.add('active');
      } else {
        memoryIndicator.classList.remove('active');
      }
    }
  });
}

// ==========================================================================
// 6. CALCULADORA DE MATRICES (ARITMÉTICA Y COMPONENTES)
// ==========================================================================

// Inicializar y Renderizar los campos de Matrices A y B
function initMatrices() {
  renderMatrixGrid('a');
  renderMatrixGrid('b');

  // Registrar escuchador para cambios de dimensiones
  selectARows.addEventListener('change', (e) => {
    matrixARows = parseInt(e.target.value);
    renderMatrixGrid('a');
  });
  selectACols.addEventListener('change', (e) => {
    matrixACols = parseInt(e.target.value);
    renderMatrixGrid('a');
  });
  selectBRows.addEventListener('change', (e) => {
    matrixBRows = parseInt(e.target.value);
    renderMatrixGrid('b');
  });
  selectBCols.addEventListener('change', (e) => {
    matrixBCols = parseInt(e.target.value);
    renderMatrixGrid('b');
  });
}

// Crear dinámicamente inputs en la cuadrícula HTML preservando valores si es posible
function renderMatrixGrid(matrixName) {
  const grid = matrixName === 'a' ? gridMatrixA : gridMatrixB;
  const rows = matrixName === 'a' ? matrixARows : matrixBCols; // Espera, matrixName === 'a' ? matrixARows : matrixBRows!
  const targetRows = matrixName === 'a' ? matrixARows : matrixBRows;
  const targetCols = matrixName === 'a' ? matrixACols : matrixBCols;

  // Respaldar valores viejos antes de borrar
  const oldVals = {};
  const cells = grid.querySelectorAll('.matrix-cell');
  cells.forEach(c => {
    oldVals[c.id] = c.value;
  });

  grid.innerHTML = '';
  grid.style.gridTemplateColumns = `repeat(${targetCols}, 1fr)`;

  for (let r = 0; r < targetRows; r++) {
    for (let c = 0; c < targetCols; c++) {
      const input = document.createElement('input');
      input.type = 'number';
      input.className = 'matrix-cell';
      input.id = `cell-${matrixName}-${r}-${c}`;
      input.placeholder = '0';
      
      // Restaurar valor previo o inicializar en vacío
      const key = `cell-${matrixName}-${r}-${c}`;
      if (oldVals[key] !== undefined) {
        input.value = oldVals[key];
      }
      
      grid.appendChild(input);
    }
  }
}

// Obtener los valores numéricos actuales de la matriz de la pantalla
function getMatrixValues(matrixName) {
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;
  const data = [];
  
  for (let r = 0; r < rows; r++) {
    const row = [];
    for (let c = 0; c < cols; c++) {
      const cell = document.getElementById(`cell-${matrixName}-${r}-${c}`);
      const val = cell ? parseFloat(cell.value) : 0;
      row.push(isNaN(val) ? 0 : val);
    }
    data.push(row);
  }
  return data;
}

// Asignar valores a las celdas de una matriz
function setMatrixValues(matrixName, values) {
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;
  
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const cell = document.getElementById(`cell-${matrixName}-${r}-${c}`);
      if (cell && values[r] && values[r][c] !== undefined) {
        cell.value = values[r][c];
      }
    }
  }
}

// Formatear Matrices para guardarlas de forma compacta en el historial
function formatMatrixForHistory(mat) {
  if (!mat) return '';
  return '[' + mat.map(row => row.map(val => formatNumber(val)).join(', ')).join('; ') + ']';
}

// Mostrar el resultado matricial en el bloque de pantalla correspondiente
function showMatrixResult(matrix, isScalar = false, scalarVal = null, errorMsg = null) {
  resultBox.innerHTML = '';
  resultActions.style.display = 'none';
  resultMatrixData = null;
  resultScalarData = null;

  if (errorMsg) {
    const errDiv = document.createElement('div');
    errDiv.className = 'matrix-error-result';
    errDiv.textContent = errorMsg;
    resultBox.appendChild(errDiv);
    return;
  }

  resultActions.style.display = 'flex';

  if (isScalar) {
    resultScalarData = scalarVal;
    const scalarSpan = document.createElement('span');
    scalarSpan.className = 'matrix-scalar-result';
    scalarSpan.textContent = formatNumber(scalarVal);
    scalarSpan.title = scalarVal;
    resultBox.appendChild(scalarSpan);
    
    // Si es un escalar, ocultamos botones de copiar a matrices y solo dejamos enviar a calcu
    btnCopyToA.style.display = 'none';
    btnCopyToB.style.display = 'none';
  } else {
    resultMatrixData = matrix;
    btnCopyToA.style.display = 'block';
    btnCopyToB.style.display = 'block';

    const rRows = matrix.length;
    const rCols = matrix[0].length;

    const wrapper = document.createElement('div');
    wrapper.className = 'matrix-grid-wrapper';
    
    const bracketLeft = document.createElement('span');
    bracketLeft.className = 'matrix-bracket left';
    bracketLeft.textContent = '[';
    
    const bracketRight = document.createElement('span');
    bracketRight.className = 'matrix-bracket right';
    bracketRight.textContent = ']';

    const gridDiv = document.createElement('div');
    gridDiv.className = 'matrix-inputs-grid';
    gridDiv.style.gridTemplateColumns = `repeat(${rCols}, 1fr)`;
    gridDiv.style.width = '160px'; // Tamaño estándar fijo para resultados de 1 o 2 celdas
    gridDiv.style.gap = '8px';

    for (let r = 0; r < rRows; r++) {
      for (let c = 0; c < rCols; c++) {
        const valSpan = document.createElement('span');
        valSpan.className = 'matrix-cell';
        valSpan.style.display = 'flex';
        valSpan.style.justifyContent = 'center';
        valSpan.style.alignItems = 'center';
        valSpan.style.background = 'rgba(255,255,255,0.03)';
        valSpan.style.border = '1px solid rgba(255,255,255,0.06)';
        valSpan.style.height = '36px';
        valSpan.textContent = formatNumber(matrix[r][c]);
        valSpan.title = matrix[r][c];
        gridDiv.appendChild(valSpan);
      }
    }

    wrapper.appendChild(bracketLeft);
    wrapper.appendChild(gridDiv);
    wrapper.appendChild(bracketRight);
    resultBox.appendChild(wrapper);
  }
}

// --- OPERACIONES ARITMÉTICAS DE MATRICES ---

// Sumar A + B
function matrixAdd() {
  if (matrixARows !== matrixBRows || matrixACols !== matrixBCols) {
    showMatrixResult(null, false, null, `Error de dimensión: Las dimensiones deben ser idénticas. (A: ${matrixARows}x${matrixACols}, B: ${matrixBRows}x${matrixBCols})`);
    return;
  }

  const matA = getMatrixValues('a');
  const matB = getMatrixValues('b');
  const result = [];

  for (let r = 0; r < matrixARows; r++) {
    const row = [];
    for (let c = 0; c < matrixACols; c++) {
      row.push(matA[r][c] + matB[r][c]);
    }
    result.push(row);
  }

  showMatrixResult(result);
  
  // Registrar en historial
  const expr = `${formatMatrixForHistory(matA)} + ${formatMatrixForHistory(matB)} =`;
  addHistoryItem('matrix', expr, formatMatrixForHistory(result), null);
}

// Restar A - B
function matrixSubtract() {
  if (matrixARows !== matrixBRows || matrixACols !== matrixBCols) {
    showMatrixResult(null, false, null, `Error de dimensión: Las dimensiones deben ser idénticas. (A: ${matrixARows}x${matrixACols}, B: ${matrixBRows}x${matrixBCols})`);
    return;
  }

  const matA = getMatrixValues('a');
  const matB = getMatrixValues('b');
  const result = [];

  for (let r = 0; r < matrixARows; r++) {
    const row = [];
    for (let c = 0; c < matrixACols; c++) {
      row.push(matA[r][c] - matB[r][c]);
    }
    result.push(row);
  }

  showMatrixResult(result);
  
  const expr = `${formatMatrixForHistory(matA)} − ${formatMatrixForHistory(matB)} =`;
  addHistoryItem('matrix', expr, formatMatrixForHistory(result), null);
}

// Multiplicar A × B
function matrixMultiply() {
  if (matrixACols !== matrixBRows) {
    showMatrixResult(null, false, null, `Error de dimensión: Las columnas de A (${matrixACols}) deben coincidir con las filas de B (${matrixBRows}).`);
    return;
  }

  const matA = getMatrixValues('a');
  const matB = getMatrixValues('b');
  const result = [];

  for (let r = 0; r < matrixARows; r++) {
    const row = [];
    for (let c = 0; c < matrixBCols; c++) {
      let sum = 0;
      for (let k = 0; k < matrixACols; k++) {
        sum += matA[r][k] * matB[k][c];
      }
      row.push(sum);
    }
    result.push(row);
  }

  showMatrixResult(result);

  const expr = `${formatMatrixForHistory(matA)} × ${formatMatrixForHistory(matB)} =`;
  addHistoryItem('matrix', expr, formatMatrixForHistory(result), null);
}

// Determinante de una Matriz
function matrixDeterminant(matrixName) {
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;

  if (rows !== cols) {
    showMatrixResult(null, false, null, `El determinante solo se puede calcular en matrices cuadradas (ej. 1x1 o 2x2).`);
    return;
  }

  const mat = getMatrixValues(matrixName);
  let det = 0;

  if (rows === 1) {
    det = mat[0][0];
  } else if (rows === 2) {
    det = mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0];
  }

  showMatrixResult(null, true, det);

  const expr = `det(${formatMatrixForHistory(mat)}) =`;
  addHistoryItem('matrix', expr, formatNumber(det), det);
}

// Inversa de una Matriz
function matrixInverse(matrixName) {
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;

  if (rows !== cols) {
    showMatrixResult(null, false, null, `La inversa solo está definida para matrices cuadradas.`);
    return;
  }

  const mat = getMatrixValues(matrixName);
  
  if (rows === 1) {
    if (mat[0][0] === 0) {
      showMatrixResult(null, false, null, `La matriz es singular (det = 0). No tiene inversa.`);
      return;
    }
    const result = [[1 / mat[0][0]]];
    showMatrixResult(result);
    addHistoryItem('matrix', `${formatMatrixForHistory(mat)}⁻¹ =`, formatMatrixForHistory(result), null);
  } else if (rows === 2) {
    const det = mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0];
    if (det === 0) {
      showMatrixResult(null, false, null, `El determinante es 0. La matriz es singular y no tiene inversa.`);
      return;
    }
    
    // Inversa 2x2 usando la adjunta
    const result = [
      [mat[1][1] / det, -mat[0][1] / det],
      [-mat[1][0] / det, mat[0][0] / det]
    ];
    
    showMatrixResult(result);
    addHistoryItem('matrix', `${formatMatrixForHistory(mat)}⁻¹ =`, formatMatrixForHistory(result), null);
  }
}

// Transpuesta de una Matriz
function matrixTranspose(matrixName) {
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;
  const mat = getMatrixValues(matrixName);
  const result = [];

  // La transpuesta cambia dimensiones: rows x cols -> cols x rows
  for (let c = 0; c < cols; c++) {
    const row = [];
    for (let r = 0; r < rows; r++) {
      row.push(mat[r][c]);
    }
    result.push(row);
  }

  showMatrixResult(result);
  addHistoryItem('matrix', `${formatMatrixForHistory(mat)}ᵀ =`, formatMatrixForHistory(result), null);
}

// Multiplicación Escalar (k * Matriz)
function matrixScalarMultiply(matrixName) {
  const valK = parseFloat(inputScalarK.value);
  if (isNaN(valK)) {
    showMatrixResult(null, false, null, `Ingresa un valor escalar numérico válido 'k'.`);
    return;
  }

  const mat = getMatrixValues(matrixName);
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;
  const result = [];

  for (let r = 0; r < rows; r++) {
    const row = [];
    for (let c = 0; c < cols; c++) {
      row.push(valK * mat[r][c]);
    }
    result.push(row);
  }

  showMatrixResult(result);
  const expr = `${formatNumber(valK)} · ${formatMatrixForHistory(mat)} =`;
  addHistoryItem('matrix', expr, formatMatrixForHistory(result), null);
}

// Configurar los escuchadores del Panel Matricial
function setupMatrixListeners() {
  // Operaciones Aritméticas Básicas
  btnMatAdd.addEventListener('click', matrixAdd);
  btnMatSub.addEventListener('click', matrixSubtract);
  btnMatMul.addEventListener('click', matrixMultiply);

  // Determinante, Inversa y Transpuesta
  btnMatDetA.addEventListener('click', () => matrixDeterminant('a'));
  btnMatDetB.addEventListener('click', () => matrixDeterminant('b'));
  btnMatInvA.addEventListener('click', () => matrixInverse('a'));
  btnMatInvB.addEventListener('click', () => matrixInverse('b'));
  btnMatTransA.addEventListener('click', () => matrixTranspose('a'));
  btnMatTransB.addEventListener('click', () => matrixTranspose('b'));

  // Escalar
  btnMatScalarA.addEventListener('click', () => matrixScalarMultiply('a'));
  btnMatScalarB.addEventListener('click', () => matrixScalarMultiply('b'));

  // Importar k de la Calculadora Científica
  btnImportK.addEventListener('click', () => {
    // Tomar el valor del visor inferior de la calculadora
    const str = inputDisplay.textContent.replace(/,/g, '');
    const floatVal = parseFloat(str);
    if (!isNaN(floatVal)) {
      inputScalarK.value = floatVal;
      animateButton(btnImportK);
    }
  });

  // Intercambiar Matrices A ↔ B
  btnSwapMatrices.addEventListener('click', () => {
    animateButton(btnSwapMatrices);
    swapMatrices();
  });

  // Limpiar campos de matrices
  btnClearMatrices.addEventListener('click', () => {
    animateButton(btnClearMatrices);
    clearMatrixCells('a');
    clearMatrixCells('b');
    
    // Ocultar resultado
    resultBox.innerHTML = '<div class="matrix-result-placeholder">Selecciona una operación de matriz para calcular el resultado.</div>';
    resultActions.style.display = 'none';
    resultMatrixData = null;
    resultScalarData = null;
  });

  // --- BOTONES DE DESTINO DEL RESULTADO ---
  btnCopyToA.addEventListener('click', () => {
    if (!resultMatrixData) return;
    animateButton(btnCopyToA);
    
    matrixARows = resultMatrixData.length;
    matrixACols = resultMatrixData[0].length;
    selectARows.value = matrixARows;
    selectACols.value = matrixACols;
    
    renderMatrixGrid('a');
    setMatrixValues('a', resultMatrixData);
  });

  btnCopyToB.addEventListener('click', () => {
    if (!resultMatrixData) return;
    animateButton(btnCopyToB);
    
    matrixBRows = resultMatrixData.length;
    matrixBCols = resultMatrixData[0].length;
    selectBRows.value = matrixBRows;
    selectBCols.value = matrixBCols;
    
    renderMatrixGrid('b');
    setMatrixValues('b', resultMatrixData);
  });

  btnSendToCalc.addEventListener('click', () => {
    animateButton(btnSendToCalc);
    let targetVal = null;
    let notice = '';

    if (resultScalarData !== null) {
      targetVal = resultScalarData;
      notice = 'Determinante enviado a la calculadora';
    } else if (resultMatrixData !== null) {
      // Si es una matriz, tomamos el elemento (1,1) -> index 0,0
      targetVal = resultMatrixData[0][0];
      notice = `Valor de celda [1,1] (${formatNumber(targetVal)}) enviado a la calculadora`;
    }

    if (targetVal !== null) {
      currentExpr = targetVal.toString();
      currentNum = targetVal.toString();
      shouldResetScreen = false;
      updateDisplay();

      // Cambiar de pestaña al módulo científico en móvil para mejor feedback
      if (window.innerWidth <= 768) {
        const sciTabBtn = document.querySelector('.tab-btn[data-tab="scientific"]');
        if (sciTabBtn) sciTabBtn.click();
      }
    }
  });

  // Delegar navegación de celdas por teclado dentro de los contenedores
  gridMatrixA.addEventListener('keydown', handleMatrixCellNavigation);
  gridMatrixB.addEventListener('keydown', handleMatrixCellNavigation);
}

// Limpiar valores de celdas de una matriz
function clearMatrixCells(matrixName) {
  const rows = matrixName === 'a' ? matrixARows : matrixBRows;
  const cols = matrixName === 'a' ? matrixACols : matrixBCols;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const cell = document.getElementById(`cell-${matrixName}-${r}-${c}`);
      if (cell) cell.value = '';
    }
  }
}

// Intercambiar contenidos y dimensiones de A y B
function swapMatrices() {
  const tempRows = matrixARows;
  const tempCols = matrixACols;
  const tempVals = getMatrixValues('a');
  
  matrixARows = matrixBRows;
  matrixACols = matrixBCols;
  matrixBRows = tempRows;
  matrixBCols = tempCols;
  
  const bVals = getMatrixValues('b');
  
  // Sincronizar selectores dropdown
  selectARows.value = matrixARows;
  selectACols.value = matrixACols;
  selectBRows.value = matrixBRows;
  selectBCols.value = matrixBCols;
  
  // Re-render
  renderMatrixGrid('a');
  renderMatrixGrid('b');
  
  // Restaurar valores cruzados
  setMatrixValues('a', bVals);
  setMatrixValues('b', tempVals);
}

// Navegar ágilmente entre celdas usando teclas de dirección y Enter
function handleMatrixCellNavigation(e) {
  if (!e.target.classList.contains('matrix-cell')) return;
  
  const parts = e.target.id.split('-'); // cell, a|b, r, c
  const matrix = parts[1];
  const r = parseInt(parts[2]);
  const c = parseInt(parts[3]);
  
  const rows = matrix === 'a' ? matrixARows : matrixBRows;
  const cols = matrix === 'a' ? matrixACols : matrixBCols;
  
  let targetRow = r;
  let targetCol = c;
  let move = false;

  if (e.key === 'ArrowRight') {
    if (c + 1 < cols) {
      targetCol = c + 1;
    } else if (r + 1 < rows) {
      targetRow = r + 1;
      targetCol = 0;
    }
    move = true;
  } else if (e.key === 'ArrowLeft') {
    if (c - 1 >= 0) {
      targetCol = c - 1;
    } else if (r - 1 >= 0) {
      targetRow = r - 1;
      targetCol = cols - 1;
    }
    move = true;
  } else if (e.key === 'ArrowDown') {
    if (r + 1 < rows) {
      targetRow = r + 1;
    }
    move = true;
  } else if (e.key === 'ArrowUp') {
    if (r - 1 >= 0) {
      targetRow = r - 1;
    }
    move = true;
  } else if (e.key === 'Enter') {
    e.preventDefault();
    if (c + 1 < cols) {
      targetCol = c + 1;
    } else if (r + 1 < rows) {
      targetRow = r + 1;
      targetCol = 0;
    } else {
      e.target.blur(); // Salir del foco en la última casilla
      return;
    }
    move = true;
  }

  if (move) {
    const nextInput = document.getElementById(`cell-${matrix}-${targetRow}-${targetCol}`);
    if (nextInput) {
      nextInput.focus();
      nextInput.select();
    }
  }
}

// ==========================================================================
// 7. GESTIÓN DE HISTORIAL (LOCAL STORAGE)
// ==========================================================================

function addHistoryItem(type, expression, result, numericResult) {
  // Crear el objeto del elemento de historial
  const item = {
    type,       // 'sci' o 'matrix'
    expression, // Expresión amigable de entrada (ej. "sin(30) + 1 =")
    result,     // Resultado formateado (ej. "1.5" o "[1, 2; 3, 4]")
    numericResult, // Valor numérico crudo (para recuperación escalar si aplica)
    timestamp: Date.now()
  };

  history.unshift(item);
  
  // Capacidad máxima de historial: 30 registros
  if (history.length > 30) {
    history.pop();
  }

  saveHistory();
  renderHistory();
}

function renderHistory() {
  historyList.innerHTML = '';
  
  if (history.length === 0) {
    historyEmptyMessage.style.display = 'block';
    return;
  }
  
  historyEmptyMessage.style.display = 'none';

  history.forEach(item => {
    const li = document.createElement('li');
    li.className = 'history-item';
    
    // Crear Badge de Tipo
    const badge = document.createElement('span');
    badge.className = `history-item-badge ${item.type === 'sci' ? 'badge-sci' : 'badge-matrix'}`;
    badge.textContent = item.type === 'sci' ? 'CIENTÍFICA' : 'MATRICES';
    
    const exprSpan = document.createElement('span');
    exprSpan.className = 'history-expr';
    exprSpan.textContent = item.expression;
    
    const resSpan = document.createElement('span');
    resSpan.className = 'history-result';
    resSpan.textContent = item.result;

    li.appendChild(badge);
    li.appendChild(exprSpan);
    li.appendChild(resSpan);

    // Evento de recuperación rápida al hacer clic en el historial
    li.addEventListener('click', () => {
      if (item.type === 'sci') {
        // Cargar expresión y resultado al visor de calculadora
        if (item.numericResult !== null) {
          currentExpr = item.numericResult.toString();
          currentNum = item.numericResult.toString();
          shouldResetScreen = true;
          updateDisplay();
        }
        
        // Pestaña científica en móviles
        if (window.innerWidth <= 768) {
          const tabBtn = document.querySelector('.tab-btn[data-tab="scientific"]');
          if (tabBtn) tabBtn.click();
        }
      } else {
        // En matrices, si el resultado fue un escalar, rellenarlo como escalar k
        if (item.numericResult !== null) {
          inputScalarK.value = item.numericResult;
        }
        
        // Pestaña matricial en móviles
        if (window.innerWidth <= 768) {
          const tabBtn = document.querySelector('.tab-btn[data-tab="matrix"]');
          if (tabBtn) tabBtn.click();
        }
      }
    });

    historyList.appendChild(li);
  });
}

function saveHistory() {
  localStorage.setItem('sci_mat_calc_history', JSON.stringify(history));
}

function loadHistory() {
  const stored = localStorage.getItem('sci_mat_calc_history');
  if (stored) {
    try {
      history = JSON.parse(stored);
    } catch (e) {
      history = [];
    }
  }
  renderHistory();

  // Historial limpiar
  btnClearHistory.addEventListener('click', () => {
    animateButton(btnClearHistory);
    history = [];
    saveHistory();
    renderHistory();
  });
}

// ==========================================================================
// 8. TECLADO FÍSICO (ATAJOS Y CONTROL POR CONSOLA)
// ==========================================================================
function setupPhysicalKeyboard() {
  document.addEventListener('keydown', (e) => {
    // Evitar interceptar atajos mientras se editan inputs de matrices o el escalar
    if (document.activeElement.classList.contains('matrix-cell') || document.activeElement === inputScalarK) {
      return;
    }

    const key = e.key;

    // Números e inputs directos
    if (/[0-9]/.test(key)) {
      handleValInput(key);
      const btn = document.querySelector(`.btn-number[data-val="${key}"]`);
      animateButton(btn);
    } else if (key === '+' || key === '-' || key === '*' || key === '/' || key === '^' || key === '%' || key === '(' || key === ')') {
      e.preventDefault();
      handleValInput(key);
      const btn = document.querySelector(`.btn-operator[data-val="${key}"], .btn-sci[data-val="${key}"]`);
      animateButton(btn);
    } else if (key === '.' || key === ',') {
      handleDecimalPoint();
      animateButton(btnDecimal);
    } else if (key === 'Enter' || key === '=') {
      e.preventDefault();
      evaluateScientific();
      animateButton(btnEquals);
    } else if (key === 'Backspace') {
      handleBackspaceChar();
      animateButton(btnBackspace);
    } else if (key === 'Escape') {
      handleClearAll();
      animateButton(btnClear);
    }
    
    // Mapeos rápidos de letras físicas para funciones científicas
    else if (key.toLowerCase() === 's') {
      // s -> sin(
      handleActionInput('sin');
      const btn = document.querySelector('.btn-sci[data-action="sin"]');
      animateButton(btn);
    } else if (key.toLowerCase() === 'c') {
      // c -> cos(
      handleActionInput('cos');
      const btn = document.querySelector('.btn-sci[data-action="cos"]');
      animateButton(btn);
    } else if (key.toLowerCase() === 't') {
      // t -> tan(
      handleActionInput('tan');
      const btn = document.querySelector('.btn-sci[data-action="tan"]');
      animateButton(btn);
    } else if (key.toLowerCase() === 'p') {
      // p -> pi
      handleValInput('pi');
      const btn = document.querySelector('.btn-sci[data-val="pi"]');
      animateButton(btn);
    } else if (key.toLowerCase() === 'e') {
      // e -> e
      handleValInput('e');
      const btn = document.querySelector('.btn-sci[data-val="e"]');
      animateButton(btn);
    } else if (key.toLowerCase() === 'l') {
      // l -> ln(
      handleActionInput('ln');
      const btn = document.querySelector('.btn-sci[data-action="ln"]');
      animateButton(btn);
    } else if (key.toLowerCase() === 'q') {
      // q -> sqrt(
      handleActionInput('sqrt');
      const btn = document.querySelector('.btn-sci[data-action="sqrt"]');
      animateButton(btn);
    } else if (key === '!') {
      handleActionInput('fact');
      const btn = document.querySelector('.btn-sci[data-action="fact"]');
      animateButton(btn);
    }
  });
}
