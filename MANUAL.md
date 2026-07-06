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

## 7. Modo Matrices

En la pestaña **Matrices**, puedes realizar operaciones avanzadas con dos matrices principales, denominadas **Matriz A** y **Matriz B** (con tamaños configurables de 1x1 a 2x2):

* **Suma (`A + B`) / Resta (`A - B`):** Suma o resta elemento por elemento. Las dimensiones de A y B deben ser exactamente iguales (ej. ambas 2x2).
* **Multiplicación (`A × B`):** Realiza la multiplicación matricial. El número de columnas de la Matriz A debe ser igual al número de filas de la Matriz B.
* **Determinante (`det(A)` / `det(B)`):** Calcula el determinante de la matriz. Solo está disponible para matrices cuadradas (1x1 o 2x2).
* **Inversa (`Inv(A)` / `Inv(B)`):** Calcula la matriz inversa. La matriz debe ser cuadrada y su determinante no debe ser cero (matriz no singular).
* **Transpuesta (`Trans(A)` / `Trans(B)`):** Intercambia las filas por columnas.
* **Multiplicación Escalar (`k * A` / `k * B`):** Multiplica cada elemento de la matriz seleccionada por un valor constante $k$ ingresado en el campo correspondiente.
* **Intercambiar (`A <-> B`):** Intercambia los valores y dimensiones cargados en la Matriz A con los de la Matriz B.
