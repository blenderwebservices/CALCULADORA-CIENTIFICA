# Manual de Usuario: Sintaxis de Operadores y Funciones

Este manual describe el funcionamiento y la sintaxis correcta de los operadores, funciones y constantes en la **Calculadora Científica y de Matrices**. Aquí encontrarás cómo utilizar cada componente correctamente y cómo evitar errores comunes de sintaxis.

---

## 1. El Operador de Módulo / Residuo (`%`)

> [!IMPORTANT]
> **El símbolo `%` en esta calculadora NO representa un porcentaje.**
> No se puede utilizar para dividir una cifra por 100 de forma directa (como `50%` para obtener `0.5`) ni para calcular incrementos porcentuales directos (como `100 + 10%`).

### ¿Qué hace el operador `%`?
Es el operador de **Módulo** o **Residuo de la División**. Devuelve el residuo que queda después de dividir el primer número por el segundo.

### Sintaxis
Es un **operador binario**, lo que significa que **requiere obligatoriamente un número a la izquierda y un número a la derecha**:
$$\text{Operando A} \ \% \ \text{Operando B}$$

* **Uso Correcto:** `10 % 3` 
  * *Resultado:* `1` (porque $10 \div 3 = 3$ y sobra $1$).
* **Uso Incorrecto:** `50%` o `10 + 5%`
  * *Resultado:* `Sintaxis inválida` (Falta el operando de la derecha).

### Cómo calcular porcentajes tradicionales
Si deseas calcular un porcentaje, debes realizar la operación aritmética equivalente:
* **Para calcular el 15% de 200:** 
  * Escribe: `200 * 15 / 100` o bien `200 * 0.15`
  * *Resultado:* `30`
* **Para sumar el 10% a 150:**
  * Escribe: `150 + (150 * 10 / 100)` o bien `150 * 1.10`
  * *Resultado:* `165`

---

## 2. Operadores Aritméticos Básicos

| Operador | Operación | Sintaxis | Ejemplo | Resultado | Notas |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **`+`** | Suma | `A + B` | `12.5 + 7.5` | `20` | También funciona como signo unario positivo: `+5`. |
| **`-`** | Resta / Negación | `A - B` o `-A` | `15 - 8` o `-5` | `7` o `-5` | Funciona como resta binaria o como signo unario negativo. |
| **`*`** | Multiplicación | `A * B` | `6 * 7` | `42` | Se muestra visualmente como `×` en la pantalla. |
| **`/`** | División | `A / B` | `20 / 4` | `5` | Se muestra visualmente como `÷`. Lanzará `División / 0` si $B = 0$. |

---

## 3. Potencias, Raíces y Factoriales

* **Potencia (`^`):** Eleva el número de la izquierda a la potencia del número de la derecha.
  * **Sintaxis:** `A ^ B`
  * **Ejemplo:** `2 ^ 3` da como resultado `8`.
  * **Ejemplo (Raíz como potencia):** `9 ^ 0.5` da como resultado `3`.
  * *Nota:* En la pantalla se puede insertar rápidamente `^2` (cuadrado), `^3` (cubo) o `^-1` (inversa/recíproco) usando los botones rápidos.
* **Factorial (`!`):** Multiplica un número entero por todos los enteros positivos menores que él.
  * **Sintaxis:** `A!` (operador unario posfijo).
  * **Ejemplo:** `5!` da como resultado `120` ($5 \times 4 \times 3 \times 2 \times 1$).
  * **Restricciones:** 
    1. El número debe ser entero.
    2. Debe ser no negativo ($A \ge 0$).
    3. Debe ser menor o igual a 170 (valores mayores provocan desbordamiento).

---

## 4. Multiplicación Implícita

Para agilizar la escritura, el motor de la calculadora inserta automáticamente el signo de multiplicación `*` (mostrado como `×`) en las siguientes situaciones:

* **Número seguido de una constante:** `2pi` o `2π` $\rightarrow$ `2 * pi` (Resultado: $\approx 6.283185$)
* **Número seguido de un paréntesis:** `2(3+4)` $\rightarrow$ `2 * (3+4)` (Resultado: `14`)
* **Número seguido de una función:** `2sin(30)` $\rightarrow$ `2 * sin(30)`
* **Paréntesis seguido de otro paréntesis:** `(2+3)(4+5)` $\rightarrow$ `(2+3) * (4+5)` (Resultado: `45`)
* **Factorial seguido de un número:** `5!2` $\rightarrow$ `5! * 2` (Resultado: `240`)

---

## 5. Constantes

La calculadora tiene integradas dos constantes matemáticas fundamentales:
* **`pi` o `π`:** Relación entre la longitud de una circunferencia y su diámetro ($\approx 3.141592653589793$).
* **`e`:** Número de Euler o constante de crecimiento exponencial ($\approx 2.718281828459045$).

---

## 6. Funciones Científicas

> [!TIP]
> **Modo de Ángulo (DEG / RAD):**
> Las funciones trigonométricas (`sin`, `cos`, `tan`, `asin`, `acos`, `atan`) se calculan en base al modo seleccionado en la pantalla:
> * **DEG:** Grados sexagesimales (por ejemplo, `sin(90)` = `1`).
> * **RAD:** Radianes (por ejemplo, `sin(pi/2)` = `1`).

Todas las funciones requieren el uso de paréntesis para encerrar su argumento (la interfaz los abre de forma automática):

| Función | Descripción | Ejemplo (DEG) | Ejemplo (RAD) | Restricciones / Dominio |
| :--- | :--- | :--- | :--- | :--- |
| **`sin(x)`** | Seno de $x$ | `sin(30)` $\rightarrow$ `0.5` | `sin(pi/6)` $\rightarrow$ `0.5` | Sin restricciones de dominio. |
| **`cos(x)`** | Coseno de $x$ | `cos(60)` $\rightarrow$ `0.5` | `cos(pi/3)` $\rightarrow$ `0.5` | Sin restricciones de dominio. |
| **`tan(x)`** | Tangente de $x$ | `tan(45)` $\rightarrow$ `1` | `tan(pi/4)` $\rightarrow$ `1` | Indefinido para $90^\circ$ (o $\pi/2$ rad) y múltiplos de $180^\circ$ sumados. |
| **`asin(x)`** | Arcoseno de $x$ | `asin(0.5)` $\rightarrow$ `30` | `asin(0.5)` $\rightarrow$ `0.523598` | El argumento $x$ debe estar entre `[-1, 1]`. |
| **`acos(x)`** | Arcocoseno de $x$ | `acos(0.5)` $\rightarrow$ `60` | `acos(0.5)` $\rightarrow$ `1.047197` | El argumento $x$ debe estar entre `[-1, 1]`. |
| **`atan(x)`** | Arcotangente de $x$ | `atan(1)` $\rightarrow$ `45` | `atan(1)` $\rightarrow$ `0.785398` | Sin restricciones de dominio. |
| **`ln(x)`** | Logaritmo natural (base $e$) | `ln(e)` $\rightarrow$ `1` | `ln(2.71828)` $\rightarrow$ `0.999999` | El argumento $x$ debe ser mayor que cero ($x > 0$). |
| **`log(x)`** | Logaritmo común (base 10) | `log(100)` $\rightarrow$ `2` | `log(10)` $\rightarrow$ `1` | El argumento $x$ debe ser mayor que cero ($x > 0$). |
| **`sqrt(x)`**| Raíz cuadrada de $x$ | `sqrt(9)` $\rightarrow$ `3` | `sqrt(2)` $\rightarrow$ `1.414213` | El argumento $x$ debe ser mayor o igual a cero ($x \ge 0$). |

---

## 7. Modo Matrices (Hasta 4x4 Eje por Eje)

En la pestaña **Matrices**, puedes realizar operaciones de álgebra lineal con dos matrices configurables, **Matriz A** y **Matriz B**, con dimensiones independientes seleccionables eje por eje de **1 a 4 filas** y de **1 a 4 columnas**:

* **Selección Dimensional:** Mediante los selectores desplegables `F` (Filas) y `C` (Columnas) puedes configurar dimensiones rectangulares o cuadradas (ej. $1\times 1, 2\times 3, 3\times 4, 4\times 4$). La interfaz y los corchetes adaptan su escala y preservan los valores previamente introducidos.
* **Suma (`A + B`) y Resta (`A - B`):** Realiza la suma o resta elemento a elemento. Requiere que las dimensiones de A y B sean idénticas.
* **Multiplicación Matricial (`A × B`):** Multiplica matrices de acuerdo a las reglas del álgebra lineal. El número de columnas de A debe coincidir con el número de filas de B (ej. $A_{3\times 4} \times B_{4\times 2} = C_{3\times 2}$).
* **Determinante (`det(A)` / `det(B)`):** Calcula el determinante exacto mediante expansión por cofactores para cualquier matriz cuadrada de orden 1, 2, 3 o 4 ($1\times 1, 2\times 2, 3\times 3, 4\times 4$).
* **Inversa (`Inv(A)` / `Inv(B)`):** Calcula la matriz inversa mediante el método de eliminación Gauss-Jordan con pivoteo parcial. Requiere que la matriz sea cuadrada y no singular ($\det \ne 0$).
* **Transpuesta (`Trans(A)` / `Trans(B)`):** Intercambia las filas por columnas ($M_{m\times n} \rightarrow M^T_{n\times m}$).
* **Multiplicación Escalar (`k · A` / `k · B`):** Multiplica cada elemento por una constante $k$. Permite importar el resultado activo de la calculadora científica con el botón *"Usar Calcu"*.
* **Intercambiar (`A ↔ B`):** Intercambia las dimensiones y celdas de la Matriz A con las de la Matriz B.

---

## 8. Calculadora de Negocios y Finanzas

La pestaña **Negocios** integra 6 módulos de cálculo comercial y financiero:

### 8.1. Préstamos y Amortización
Calcula la cuota mensual periódica fija (sistema de amortización francés), monto total devuelto e intereses totales acumulados:
$$M = P \cdot \frac{i(1+i)^n}{(1+i)^n - 1}$$
* $P$: Monto del préstamo.
* $i$: Tasa de interés mensual ($r / 12 / 100$).
* $n$: Número de mensualidades.

### 8.2. Interés Compuesto y Simple
Permite proyectar el crecimiento de un capital inicial con aportes mensuales periódicos:
* **Interés Compuesto:** $A = P\left(1 + \frac{r}{n}\right)^{nt} + \text{PMT} \cdot \frac{(1 + r/12)^{12t} - 1}{r/12}$
* **Interés Simple:** $I = P \cdot r \cdot t$

### 8.3. Punto de Equilibrio (Break-Even)
Determina el volumen mínimo de ventas para absorber los costos fijos sin generar pérdidas ni ganancias:
$$\text{Unidades} = \frac{\text{Costos Fijos}}{\text{Precio de Venta Unitario} - \text{Costo Variable Unitario}}$$

### 8.4. Margen de Ganancia y Markup
Calcula la relación entre el costo del producto y su precio de venta:
* **Margen Bruto (%):** $\frac{\text{Precio Venta} - \text{Costo}}{\text{Precio Venta}} \times 100$
* **Markup sobre Costo (%):** $\frac{\text{Precio Venta} - \text{Costo}}{\text{Costo}} \times 100$

### 8.5. Retorno de Inversión (ROI)
Mide el porcentaje de rendimiento neto generado sobre una inversión inicial:
$$\text{ROI (\%)} = \frac{\text{Ingreso Obtenido} - \text{Inversión}}{\text{Inversión}} \times 100$$

### 8.6. Impuestos / IVA
* **Agregar IVA (Neto $\rightarrow$ Bruto):** $\text{Total} = \text{Base} \times (1 + \text{IVA}\%)$.
* **Desglosar IVA (Bruto $\rightarrow$ Neto):** $\text{Subtotal} = \frac{\text{Total}}{1 + \text{IVA}\%}$, con $\text{IVA} = \text{Total} - \text{Subtotal}$.
* Incluye botones de acceso rápido para tasas estándar (16%, 21%, 10%, 8%, 0%).

---

## 9. Graficador de Funciones 2D

La pestaña **Gráficas** proporciona un entorno interactivo en tiempo real para visualizar y estudiar funciones matemáticas:

* **Sintaxis de Entrada:** Introduce funciones en términos de la variable $x$ (o $X$). Soporta multiplicación implícita (ej. `2x`, `x(x+1)`, `x^2`, `x sin(x)`).
* **Presets Rápidos:** Botones de un toque para funciones elementales: $\sin(x)$, $\cos(x)$, $\tan(x)$, $x^2 - 4$, $x^3 - 3x$, $1/x$, $\sqrt{x}$, $e^x$, $\ln(x)$, $\text{abs}(x)$.
* **Controles Gestuales:**
  * **Arrastre / Pan:** Mueve el lienzo cartesiano en cualquier dirección.
  * **Zoom (+ / -):** Escala el plano para estudiar comportamiento asíntotico o local.
  * **Centrar (0,0):** Restablece la vista al origen cartesiano estándar.
* **Inspección de Puntos:** Al pulsar o arrastrar el dedo sobre la gráfica, se proyecta un cursor con línea guía y una insignia con las coordenadas exactas $(x, y)$.
* **Conmutador Angular:** Alterna entre grados sexagesimales (**DEG**) y radianes (**RAD**) para funciones trigonométricas.
* **Tabla de Valores:** Muestra una tabla comparativa de valores $x \rightarrow f(x)$ para un análisis puntual rápido.

