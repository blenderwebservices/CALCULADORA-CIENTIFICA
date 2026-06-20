# Calculadora Científica & Matricial Premium

Una aplicación multiplataforma moderna y premium construida con **Flutter** y **Dart**, que proporciona herramientas matemáticas avanzadas con un diseño táctil glassmorphism (vidrio esmerilado) fluido y totalmente responsivo.

Esta app fue convertida de su versión web original a Flutter, manteniendo toda la lógica matemática del parser matemático personalizado y adaptando el diseño a dispositivos móviles, tabletas y computadoras de escritorio.

---

## 🚀 Características Principales

### 1. Calculadora Científica
- **Motor de Parseo Personalizado:** Utiliza una implementación en Dart del algoritmo **Shunting-Yard** con conversión RPN (Reverse Polish Notation) para evaluar operaciones matemáticas con precisión.
- **Operaciones Avanzadas:** Soporta funciones trigonométricas (`sin`, `cos`, `tan`, `asin`, `acos`, `atan`), logaritmos (`ln`, `log`), raíces (`sqrt`), factoriales (`x!`), potencias (`xʸ`, `x²`, `x³`) y constantes (`π`, `e`).
- **Modos de Ángulo:** Alternancia rápida entre Grados (`DEG`) y Radianes (`RAD`).
- **Controles de Memoria:** Soporte de almacenamiento de memoria completo (`MC`, `MR`, `M+`, `M-`, `MS`).

### 2. Calculadora de Matrices
- **Matrices 2x2 Interactivas:** Celdas dinámicas para entrada de datos numéricos en las matrices A y B.
- **Ajuste de Dimensiones:** Permite seleccionar dimensiones entre 1x1 y 2x2 dinámicamente.
- **Operaciones Matriciales:** Suma (`A+B`), Resta (`A-B`), Multiplicación (`A×B`), Transpuesta (`Aᵀ`), Determinante (`det`) e Inversa (`A⁻¹`).
- **Aritmética Escalar:** Multiplicación por escalar `k`, con la posibilidad de importar el valor `k` directamente desde la pantalla de la calculadora científica.
- **Copiar y Transferir:** Opciones para copiar la matriz resultado de vuelta a A o B, o enviar el resultado escalar al visor de la calculadora.

### 3. Historial de Operaciones
- Lista de operaciones recientes clasificada con etiquetas de tipo (`CIENTÍFICA` o `MATRICES`).
- Al presionar un registro del historial, este se carga automáticamente en el módulo correspondiente (e incluye cambio automático de pestaña en móviles).
- Persistencia local del historial utilizando `shared_preferences`.

---

## 🏛️ Arquitectura de la Aplicación

El proyecto sigue una estructura limpia y reactiva en la carpeta `lib/`:

*   **`main.dart`**: Punto de entrada de la aplicación. Configura la estética visual oscura general, la tipografía corporativa y el comportamiento de la barra de estado del sistema.
*   **`models/`**: Contiene la definición de datos (ej. [HistoryItem](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/models/history_item.dart)) y su serialización a formato JSON para persistencia.
*   **`utils/`**: Alberga los motores lógicos y matemáticos:
    - [math_parser.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/utils/math_parser.dart): Tokenizer, Shunting-Yard Parser y postfix evaluator.
    - [matrix_ops.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/utils/matrix_ops.dart): Operaciones aritméticas y métodos matriciales.
    - [calculator_state.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/utils/calculator_state.dart): Estado centralizado y reactivo de la aplicación que hereda de `ChangeNotifier` (gestión de estado nativa de Flutter).
*   **`widgets/`**: Elementos visuales reutilizables:
    - [glass_container.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/widgets/glass_container.dart): Diseña el efecto glassmorphism premium con gradientes de borde y difuminado por software (`BackdropFilter`).
    - [calc_button.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/widgets/calc_button.dart): Estila y anima los botones (efecto de rebote/escala al pulsarse).
*   **`screens/`**: Vistas principales de la app ([home_screen.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/screens/home_screen.dart), [scientific_screen.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/screens/scientific_screen.dart), [matrix_screen.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/screens/matrix_screen.dart), [history_screen.dart](file:///Users/oscarcaloca/HERD/CALCULADORA%20CIENTIFICA/lib/screens/history_screen.dart)). La vista `HomeScreen` actúa como controlador responsivo cambiando de layout por pestañas a grid de columnas según el ancho de pantalla mediante `LayoutBuilder`.

---

## 🛠️ Comandos Principales de Flutter

Utiliza los siguientes comandos en tu terminal (asegúrate de estar en el directorio raíz de la aplicación) para correr y mantener tu app al día:

### 1. Gestión de Dependencias
*   **Instalar dependencias:** Descarga todas las librerías configuradas en el archivo `pubspec.yaml`.
    ```bash
    flutter pub get
    ```
*   **Ver dependencias obsoletas:** Muestra cuáles librerías de tu app tienen actualizaciones disponibles en pub.dev.
    ```bash
    flutter pub outdated
    ```
*   **Actualizar dependencias:** Actualiza tus paquetes automáticamente respetando las restricciones del archivo.
    ```bash
    flutter pub upgrade
    ```

### 2. Ejecutar la Aplicación
*   **Ejecutar en tu dispositivo o emulador por defecto:**
    ```bash
    flutter run
    ```
*   **Ejecutar específicamente en el navegador web (Chrome):**
    ```bash
    flutter run -d chrome
    ```
*   **Ejecutar específicamente como aplicación macOS nativa:**
    ```bash
    flutter run -d macos
    ```

### 3. Calidad de Código y Análisis
*   **Analizar el código:** Revisa estáticamente tu código Dart en busca de errores de sintaxis, advertencias o malas prácticas.
    ```bash
    flutter analyze
    ```
*   **Formatear automáticamente el código:** Aplica el formato estándar de Dart a todos los archivos del proyecto.
    ```bash
    flutter format .
    ```

### 4. Compilación para Producción (Build)
*   **Compilar para la Web:** Genera los archivos estáticos listos para desplegar en producción en la carpeta `build/web/`.
    ```bash
    flutter build web
    ```
*   **Compilar para macOS:** Compila la aplicación de escritorio nativa firmada para macOS.
    ```bash
    flutter build macos
    ```
*   **Compilar para Android (APK):** Genera el instalador APK ejecutable en emuladores o móviles Android.
    ```bash
    flutter build apk
    ```
