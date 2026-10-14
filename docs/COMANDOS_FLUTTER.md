# Guía de Comandos Flutter Más Útiles y Usados

Esta guía recopila los comandos de Flutter y Dart más utilizados en el desarrollo diario, organizados por categorías, incluyendo herramientas de diagnóstico, gestión de dependencias, ejecución, análisis y compilación multiplataforma.

---

## 1. Diagnóstico y Configuración del Entorno

| Comando | Descripción |
| :--- | :--- |
| `flutter doctor` | Analiza el sistema y reporta dependencias, herramientas o SDKs faltantes. |
| `flutter doctor -v` | Modo verbose: muestra información detallada de cada componente (rutas, versiones, herramientas instaladas). |
| `flutter --version` | Muestra la versión actual de Flutter y Dart SDK instaladas. |
| `flutter channel` | Lista los canales disponibles (`stable`, `beta`, `master`) y resalta el canal activo. |
| `flutter channel stable` | Cambia al canal estable oficial recomendado para producción. |
| `flutter upgrade` | Actualiza el SDK de Flutter a la versión más reciente del canal seleccionado. |
| `flutter downgrade` | Regresa a la versión previa de Flutter (si está disponible en caché local). |
| `flutter config` | Muestra las banderas de configuración global de Flutter. |
| `flutter config --enable-web` | Habilita soporte para aplicaciones Web en el SDK. |
| `flutter config --enable-windows-desktop` | Habilita soporte para aplicaciones de escritorio Windows. |
| `flutter config --enable-macos-desktop` | Habilita soporte para aplicaciones de escritorio macOS. |
| `flutter config --enable-linux-desktop` | Habilita soporte para aplicaciones de escritorio Linux. |

---

## 2. Dispositivos y Emuladores

| Comando | Descripción |
| :--- | :--- |
| `flutter devices` | Lista todos los dispositivos físicos conectados, emuladores activos y navegadores disponibles. |
| `flutter emulators` | Muestra todos los emuladores (Android) o simuladores (iOS) configurados en el equipo. |
| `flutter emulators --launch <id_emulador>` | Inicia un emulador específico sin necesidad de abrir Android Studio. |
| `flutter emulators --create [--name <nombre>]` | Crea un nuevo emulador de Android desde la consola. |

---

## 3. Creación y Configuración de Proyectos

| Comando | Descripción |
| :--- | :--- |
| `flutter create <nombre_proyecto>` | Crea un nuevo proyecto con la estructura básica recomendada. |
| `flutter create --org com.miempresa <nombre_proyecto>` | Define el dominio reverso de la organización (define el package name en Android y Bundle ID en iOS). |
| `flutter create --platforms=android,ios,web <nombre>` | Crea un proyecto limitando el soporte inicial únicamente a las plataformas especificadas. |
| `flutter create .` | Ejecutado dentro de un proyecto existente, regenera o añade carpetas de plataformas faltantes (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`). |

---

## 4. Gestión de Paquetes y Dependencias (`pub`)

| Comando | Descripción |
| :--- | :--- |
| `flutter pub get` | Descarga e instala todas las dependencias declaradas en `pubspec.yaml`. |
| `flutter pub add <paquete>` | Añade un paquete a `pubspec.yaml` e instala la última versión compatible. |
| `flutter pub add dev:<paquete>` | Añade una dependencia de desarrollo (`dev_dependencies`). |
| `flutter pub remove <paquete>` | Remueve un paquete del archivo `pubspec.yaml` y actualiza el árbol de dependencias. |
| `flutter pub outdated` | Analiza el archivo de bloqueo y lista paquetes con versiones desactualizadas o con soporte nulo. |
| `flutter pub upgrade` | Actualiza los paquetes a la versión más alta permitida por las reglas de `pubspec.yaml`. |
| `flutter pub upgrade --major-versions` | Actualiza los paquetes a sus versiones mayores más recientes (puede requerir cambios de código). |
| `flutter pub cache clean` | Limpia la caché global de paquetes descargados. |
| `flutter pub cache repair` | Descarga y reinstala nuevamente todos los paquetes en caché (útil si hay paquetes corruptos). |

---

## 5. Ejecución y Depuración (`run`)

| Comando | Descripción |
| :--- | :--- |
| `flutter run` | Inicia la app en el dispositivo predeterminado o pregunta si hay varios disponibles. |
| `flutter run -d <id_dispositivo>` | Ejecuta la app en un dispositivo específico (ej. `flutter run -d chrome` o `flutter run -d macos`). |
| `flutter run -d all` | Ejecuta la app simultáneamente en todos los dispositivos conectados. |
| `flutter run --debug` | Ejecuta en modo depuración con soporte para hot reload y DevTools (modo por defecto). |
| `flutter run --profile` | Ejecuta con optimizaciones pero manteniendo herramientas de perfilado de rendimiento y memoria. |
| `flutter run --release` | Ejecuta la app compilada para máxima velocidad, sin herramientas de depuración. |
| `flutter run --dart-define=ENV=prod` | Pasa variables de entorno o configuración en tiempo de compilación. |
| `flutter run -t lib/main_dev.dart` | Especifica un punto de entrada alternativo (útil para múltiples entornos o flavors). |

### Atajos interactivos durante la ejecución en consola
Una vez que `flutter run` está en ejecución, presiona las siguientes teclas en la terminal:
* **`r`**: **Hot Reload** (recarga instantánea de cambios en la interfaz sin perder el estado).
* **`R`**: **Hot Restart** (reinicia la aplicación y el estado completo).
* **`h`**: Muestra la lista de atajos disponibles.
* **`p`**: Muestra la cuadrícula de renderizado (*debug paint visual*).
* **`o`**: Alterna la simulación de sistema operativo entre Android e iOS.
* **`c`**: Limpia la pantalla de la terminal.
* **`q`**: Detiene la ejecución y desconecta la sesión.

---

## 6. Mantenimiento, Limpieza y Pruebas

| Comando | Descripción |
| :--- | :--- |
| `flutter clean` | Borra el directorio `build/` y los archivos temporales generados. Soluciona la mayoría de inconsistencias de compilación. |
| `flutter analyze` | Analiza el código fuente con el linter de Dart y reporta errores, advertencias y sugerencias. |
| `dart format .` | Formatea automáticamente todos los archivos `.dart` del proyecto bajo las directrices oficiales. |
| `flutter test` | Ejecuta todas las pruebas unitarias y de widgets en el directorio `test/`. |
| `flutter test --coverage` | Ejecuta pruebas y genera reporte de cobertura en `coverage/lcov.info`. |

### Generación de código (`build_runner`)
Para proyectos que usan generadores (como `freezed`, `json_serializable`, `riverpod_generator`, etc.):
```bash
# Genera los archivos una sola vez resolviendo conflictos existentes
dart run build_runner build --delete-conflicting-outputs

# Modo escucha continua: regenera automáticamente al guardar cambios
dart run build_runner watch --delete-conflicting-outputs
```

---

## 7. Generación y Compilación de Aplicaciones por Plataforma (`flutter build`)

Esta sección detalla los comandos para generar los instalables y binarios finales de producción para cada plataforma soportada.

> [!TIP]
> **Recomendación antes de compilar:**
> Ejecuta siempre `flutter clean` seguido de `flutter pub get` antes de generar binarios de producción para evitar arrastrar artefactos cacheados de versiones previas:
> ```bash
> flutter clean && flutter pub get
> ```

---

### 7.1. Android

#### 1. APK Universal (Fat APK)
Genera un archivo `.apk` completo que incluye todas las arquitecturas de procesador (ARM, ARM64, x86_64).
```bash
flutter build apk --release
```
* **Ubicación de salida:** `build/app/outputs/flutter-apk/app-release.apk`
* **Uso:** Ideal para pruebas internas, envío directo por correo o distribución manual sin Play Store.

#### 2. APKs divididos por arquitectura (`Split per ABI`)
Genera múltiples APKs, cada uno optimizado para una arquitectura de CPU específica, reduciendo significativamente el peso de descarga.
```bash
flutter build apk --split-per-abi --release
```
* **Archivos generados:**
  * `app-armeabi-v7a-release.apk` (dispositivos antiguos de 32 bits)
  * `app-arm64-v8a-release.apk` (la gran mayoría de dispositivos modernos de 64 bits)
  * `app-x86_64-release.apk` (emuladores y dispositivos x86_64)

#### 3. Android App Bundle (AAB - Recomendado para Google Play)
El formato oficial y requerido para publicar en Google Play Store. Google Play se encarga de generar los APKs optimizados para cada usuario.
```bash
flutter build appbundle --release
```
* **Ubicación de salida:** `build/app/outputs/bundle/release/app-release.aab`

---

### 7.2. iOS

> [!NOTE]
> Para compilar y firmar aplicaciones de iOS es obligatorio contar con un equipo con **macOS** y **Xcode** configurado con certificados y perfiles de aprovisionamiento de Apple Developer.

#### 1. Generar Bundle para Xcode
Genera el directorio `.app` listo para ser inspeccionado o compilado desde Xcode:
```bash
flutter build ios --release
```
* **Ubicación de salida:** `build/ios/iphoneos/Runner.app`

#### 2. Generar archivo `.ipa` (App Store y distribución Ad-Hoc / TestFlight)
Compila la app y empaqueta directamente el instalador `.ipa`:
```bash
flutter build ipa --release
```
* **Ubicación de salida:** `build/ios/archive/Runner.xcarchive` y `build/ios/ipa/*.ipa`

#### 3. Compilación sin firma de certificados (Útil para pipelines CI/CD previos a la firma)
```bash
flutter build ios --release --no-codesign
```

---

### 7.3. Web

Genera los archivos estáticos HTML, JS, CSS y Canvas/Wasm listos para ser desplegados en cualquier servidor web, hosting o CDN (Firebase Hosting, Cloudflare Pages, Nginx, Apache, Vercel, etc.).

#### 1. Compilación Web Estándar
```bash
flutter build web --release
```
* **Ubicación de salida:** `build/web/`

#### 2. Compilación con Base Href personalizada
Si la aplicación no se va a servir en la raíz del dominio sino en una subcarpeta (ej. `https://midominio.com/app/`):
```bash
flutter build web --base-href "/app/" --release
```

#### 3. Compilación WebAssembly (WASM - Flutter moderno)
Para obtener el máximo rendimiento gráfico en navegadores compatibles con soporte WasmGC:
```bash
flutter build web --wasm --release
```

---

### 7.4. Windows (Escritorio)

> [!NOTE]
> Requiere un equipo con Windows y las herramientas C++ de Visual Studio instaladas.

Compila el ejecutable `.exe` nativo de 64 bits para Windows:
```bash
flutter build windows --release
```
* **Ubicación de salida:** `build/windows/x64/runner/Release/`
* **Distribución:** La carpeta generada contiene el ejecutable (`.exe`) junto con sus DLLs y recursos dependientes.

---

### 7.5. macOS (Escritorio)

> [!NOTE]
> Requiere macOS y Xcode configurado.

Compila el paquete nativo `.app` para macOS:
```bash
flutter build macos --release
```
* **Ubicación de salida:** `build/macos/Build/Products/Release/`
* **Resultado:** Un paquete de aplicación `.app` listo para ejecutar o empaquetar en `.dmg` / `.pkg` para distribución o Mac App Store.

---

### 7.6. Linux (Escritorio)

> [!NOTE]
> Requiere un entorno Linux con `clang`, `cmake`, `ninja-build` y las librerías de desarrollo GTK3 instaladas (`libgtk-3-dev`).

Compila el binario ejecutable nativo para distribuciones Linux:
```bash
flutter build linux --release
```
* **Ubicación de salida:** `build/linux/x64/release/bundle/`
* **Distribución:** La carpeta `bundle/` contiene el binario ejecutable y sus dependencias compartidas necesarias.

---

## 8. Modificadores y Opciones Comunes de Compilación

Los siguientes argumentos pueden combinarse con los comandos `flutter build`:

| Parámetro | Ejemplo de Uso | Propósito |
| :--- | :--- | :--- |
| `--dart-define` | `--dart-define=API_URL=https://api.ejemplo.com` | Inyecta variables de configuración en tiempo de compilación accesibles mediante `String.fromEnvironment()`. |
| `--flavor` | `--flavor production` | Selecciona un flavor/esquema configurado en Gradle o Xcode (ej. dev, staging, prod). |
| `--target` (`-t`) | `-t lib/main_prod.dart` | Especifica un archivo de entrada principal diferente a `lib/main.dart`. |
| `--obfuscate` | `--obfuscate --split-debug-info=./debug_symbols` | Ofusca los símbolos del código Dart para dificultar la ingeniería inversa y guarda los símbolos para depuración de crashes. |
| `--tree-shake-icons` | `--tree-shake-icons` | Remueve los glifos de fuentes de íconos que no se utilizan en la aplicación para reducir el tamaño final. |
