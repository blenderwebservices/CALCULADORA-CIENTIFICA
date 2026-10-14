# Guía Completa de Comandos de Flutter

Este documento contiene una referencia práctica y concisa de los comandos más utilizados en el desarrollo con **Flutter**, junto con su sintaxis formal, parámetros habituales y ejemplos de uso. Al final se detallan los comandos específicos para crear proyectos dirigidos a **Android, iOS, macOS y Windows**.

---

## Tabla de Contenido
1. [Diagnóstico y Configuración del Entorno](#1-diagnóstico-y-configuración-del-entorno)
2. [Gestión de Paquetes y Dependencias (`pub`)](#2-gestión-de-paquetes-y-dependencias-pub)
3. [Ejecución y Depuración](#3-ejecución-y-depuración)
4. [Compilación y Construcción (`build`)](#4-compilación-y-construcción-build)
5. [Análisis, Pruebas y Limpieza](#5-análisis-pruebas-y-limpieza)
6. [Gestión de Canales y Versiones de Flutter](#6-gestión-de-canales-y-versiones-de-flutter)
7. [Creación de Aplicaciones (Android, iOS, macOS, Windows)](#7-creación-de-aplicaciones-android-ios-macos-windows)
   - [Estructura y Parámetros de `flutter create`](#estructura-y-parámetros-de-flutter-create)
   - [Creación Exclusiva para Android](#creación-exclusiva-para-android)
   - [Creación Exclusiva para iOS](#creación-exclusiva-para-ios)
   - [Creación Exclusiva para macOS](#creación-exclusiva-para-macos)
   - [Creación Exclusiva para Windows](#creación-exclusiva-para-windows)
   - [Creación Multiplataforma Combinada](#creación-multiplataforma-combinada)
   - [Habilitar o Agregar Plataformas a un Proyecto Existente](#habilitar-o-agregar-plataformas-a-un-proyecto-existente)

---

## 1. Diagnóstico y Configuración del Entorno

### `flutter doctor`
Verifica el estado de las herramientas instaladas (Flutter SDK, Android Studio, Xcode, VS Code, dispositivos conectados) e informa sobre dependencias faltantes.

* **Estructura:**
  ```bash
  flutter doctor [opciones]
  ```
* **Parámetros principales:**
  * `-v`, `--verbose`: Muestra un reporte detallado con versiones exactas, rutas y variables de entorno.
  * `--android-licenses`: Inicia el asistente interactivo para aceptar todas las licencias del SDK de Android.
* **Ejemplos:**
  ```bash
  flutter doctor
  flutter doctor -v
  flutter doctor --android-licenses
  ```

---

### `flutter devices`
Lista todos los dispositivos físicos, emuladores y navegadores disponibles para ejecutar la aplicación.

* **Estructura:**
  ```bash
  flutter devices [opciones]
  ```
* **Parámetros principales:**
  * `-d <device-id>`: Filtra por un identificador específico.
* **Ejemplo:**
  ```bash
  flutter devices
  ```

---

### `flutter emulators`
Muestra y permite gestionar los emuladores o simuladores configurados en el sistema.

* **Estructura:**
  ```bash
  flutter emulators [opciones]
  ```
* **Parámetros principales:**
  * `--launch <emulator-id>`: Inicia el emulador indicado por su ID.
  * `--create [--name <nombre>]`: Crea un nuevo emulador de Android (si está soportado).
* **Ejemplos:**
  ```bash
  flutter emulators
  flutter emulators --launch Pixel_7_API_34
  flutter emulators --launch apple_ios_simulator
  ```

---

## 2. Gestión de Paquetes y Dependencias (`pub`)

### `flutter pub get`
Descarga e instala las dependencias declaradas en el archivo `pubspec.yaml`.

* **Estructura:**
  ```bash
  flutter pub get [opciones]
  ```
* **Parámetros principales:**
  * `--offline`: Utiliza únicamente los paquetes disponibles en la caché local sin realizar peticiones de red.
* **Ejemplo:**
  ```bash
  flutter pub get
  ```

---

### `flutter pub add`
Agrega una o más dependencias al archivo `pubspec.yaml` y las descarga automáticamente.

* **Estructura:**
  ```bash
  flutter pub add [opciones] <nombre_paquete>
  ```
* **Parámetros principales:**
  * `-d`, `--dev`: Agrega el paquete en la sección `dev_dependencies`.
  * `--path <ruta>`: Instala un paquete local desde una ruta del disco.
  * `--git-url <url>`: Instala el paquete directamente desde un repositorio Git.
* **Ejemplos:**
  ```bash
  flutter pub add provider
  flutter pub add -d flutter_lints
  flutter pub add mi_libreria --path ../librerias/mi_libreria
  ```

---

### `flutter pub remove`
Elimina dependencias del archivo `pubspec.yaml` y actualiza el archivo `pubspec.lock`.

* **Estructura:**
  ```bash
  flutter pub remove <nombre_paquete>
  ```
* **Ejemplo:**
  ```bash
  flutter pub remove provider
  ```

---

### `flutter pub upgrade`
Actualiza los paquetes a las versiones más recientes permitidas por las restricciones del archivo `pubspec.yaml`.

* **Estructura:**
  ```bash
  flutter pub upgrade [opciones]
  ```
* **Parámetros principales:**
  * `--major-versions`: Modifica el archivo `pubspec.yaml` para actualizar dependencias que incluyan cambios de versión mayor (breaking changes).
* **Ejemplo:**
  ```bash
  flutter pub upgrade
  flutter pub upgrade --major-versions
  ```

---

### `flutter pub outdated`
Analiza las dependencias instaladas y reporta cuáles tienen versiones más recientes disponibles en pub.dev.

* **Estructura:**
  ```bash
  flutter pub outdated
  ```

---

## 3. Ejecución y Depuración

### `flutter run`
Compila y ejecuta la aplicación en un dispositivo físico, emulador o navegador conectado, con soporte para *Hot Reload* (`r`) y *Hot Restart* (`R`).

* **Estructura:**
  ```bash
  flutter run [opciones]
  ```
* **Parámetros principales:**
  * `-d <id>`, `--device-id <id>`: Especifica el dispositivo de destino (ej. `macos`, `windows`, `chrome`, o ID del dispositivo móvil).
  * `-t <ruta>`, `--target <ruta>`: Ruta del archivo de entrada principal (por defecto `lib/main.dart`).
  * `--debug`: Modo de depuración (predeterminado). Permite Hot Reload y DevTools.
  * `--profile`: Modo de perfilado para análisis de rendimiento y consumo de memoria.
  * `--release`: Modo de producción optimizado (desactiva depuración y Hot Reload).
  * `--flavor <nombre>`: Ejecuta una variante específica del proyecto (e.g. `dev`, `qa`, `prod`).
  * `--dart-define <CLAVE=VALOR>`: Pasa variables de entorno en tiempo de compilación.
* **Ejemplos:**
  ```bash
  flutter run
  flutter run -d macos
  flutter run -d windows
  flutter run -d chrome --web-renderer canvaskit
  flutter run --release --dart-define=API_URL=https://api.midominio.com
  ```

---

### `flutter attach`
Conecta el entorno de depuración de Flutter a una aplicación que ya está corriendo en un dispositivo.

* **Estructura:**
  ```bash
  flutter attach [opciones]
  ```
* **Parámetros principales:**
  * `-d <id>`, `--device-id <id>`: Identificador del dispositivo.
  * `--debug-url <url>`: URL del servicio de depuración (observatory / VM Service) de la app en ejecución.
* **Ejemplo:**
  ```bash
  flutter attach -d emulator-5554
  ```

---

## 4. Compilación y Construcción (`build`)

Los comandos de compilación generan los binarios finales para distribución o pruebas.

* **Estructura general:**
  ```bash
  flutter build <subcomando> [opciones]
  ```

### Subcomandos por plataforma y opciones comunes:

| Subcomando | Propósito | Formato Generado | Opciones Clave |
| :--- | :--- | :--- | :--- |
| **`flutter build apk`** | Genera instalador Android | `.apk` en `build/app/outputs/flutter-apk/` | `--split-per-abi`, `--release` |
| **`flutter build appbundle`** | Paquete para Google Play Store | `.aab` en `build/app/outputs/bundle/release/` | `--release`, `--flavor <nombre>` |
| **`flutter build ios`** | Compila la app para iOS | Estructura en `build/ios/iphoneos/` | `--release`, `--no-codesign` |
| **`flutter build ipa`** | Paquete de distribución iOS / App Store | `.ipa` en `build/ios/ipa/` | `--export-options-plist <ruta>` |
| **`flutter build macos`** | Ejecutable para escritorio macOS | `.app` en `build/macos/Build/Products/Release/` | `--release` |
| **`flutter build windows`** | Ejecutable para escritorio Windows | `.exe` en `build/windows/x64/runner/Release/` | `--release` |
| **`flutter build web`** | Aplicación web estática | Directorio `build/web/` | `--release`, `--web-renderer <auto\|canvaskit>` |

* **Parámetros de optimización recomendados:**
  * `--obfuscate`: Ofusca el código Dart compilado para dificultar la ingeniería inversa.
  * `--split-debug-info=<directorio>`: Extrae los símbolos de depuración en archivos externos para reducir el tamaño final del binario.
* **Ejemplo de build seguro y optimizado:**
  ```bash
  flutter build appbundle --release --obfuscate --split-debug-info=./debug_symbols
  ```

---

## 5. Análisis, Pruebas y Limpieza

### `flutter analyze`
Ejecuta el linter estático de Dart para detectar advertencias de estilo, malas prácticas y errores sintácticos.

* **Estructura:**
  ```bash
  flutter analyze [directorio] [opciones]
  ```
* **Parámetros principales:**
  * `--fatal-infos`: Trata las notas informativas como errores que detienen la compilación/CI.
  * `--fatal-warnings`: Trata las advertencias como errores.
* **Ejemplo:**
  ```bash
  flutter analyze
  flutter analyze --fatal-warnings
  ```

---

### `dart format`
Formatea el código fuente siguiendo las convenciones oficiales del equipo de Dart.

* **Estructura:**
  ```bash
  dart format <ruta_o_directorio> [opciones]
  ```
* **Parámetros principales:**
  * `-l <número>`, `--line-length <número>`: Establece el límite de caracteres por línea (por defecto 80).
  * `-o <modo>`, `--output <modo>`: Modo de salida (`write` para sobrescribir archivos, `none` para verificar sin modificar).
* **Ejemplo:**
  ```bash
  dart format lib/ test/
  dart format -l 100 lib/
  ```

---

### `flutter test`
Ejecuta las pruebas unitarias y de widgets del proyecto.

* **Estructura:**
  ```bash
  flutter test [archivo_o_directorio] [opciones]
  ```
* **Parámetros principales:**
  * `--coverage`: Genera un informe de cobertura de código en `coverage/lcov.info`.
  * `-p <plataforma>`, `--platform <plataforma>`: Plataforma de ejecución de tests (ej. `vm`, `chrome`).
  * `--plain-name "<texto>"`: Filtra y ejecuta solo las pruebas cuya descripción contenga el texto dado.
* **Ejemplos:**
  ```bash
  flutter test
  flutter test test/widget_test.dart
  flutter test --coverage
  ```

---

### `flutter clean`
Elimina los directorios de compilación (`build/`) y la caché de plugins generados. Resuelve errores comunes de compilación tras cambios de dependencias o versiones de SDK.

* **Estructura:**
  ```bash
  flutter clean
  ```
* **Flujo habitual tras limpiar:**
  ```bash
  flutter clean && flutter pub get
  ```

---

## 6. Gestión de Canales y Versiones de Flutter

### `flutter channel`
Muestra el canal de desarrollo actual o cambia a otro canal oficial (`stable`, `beta`, `master`).

* **Estructura:**
  ```bash
  flutter channel [<nombre_canal>]
  ```
* **Ejemplos:**
  ```bash
  flutter channel
  flutter channel stable
  ```

---

### `flutter upgrade`
Actualiza el SDK de Flutter y el SDK de Dart a la versión más reciente del canal actual.

* **Estructura:**
  ```bash
  flutter upgrade [opciones]
  ```
* **Parámetros principales:**
  * `--force`: Fuerza la actualización incluso si hay cambios locales no guardados en el SDK.
* **Ejemplo:**
  ```bash
  flutter upgrade
  ```

---

## 7. Creación de Aplicaciones (Android, iOS, macOS, Windows)

El comando `flutter create` inicializa la estructura de un nuevo proyecto Flutter configurando los archivos nativos correspondientes.

### Estructura y Parámetros de `flutter create`

```bash
flutter create [opciones] <directorio_del_proyecto>
```

#### Parámetros fundamentales:

| Parámetro | Sintaxis / Opciones | Descripción |
| :--- | :--- | :--- |
| **`--org`** | `--org <dominio_invertido>` | Prefijo de organización / paquete (ej. `com.miempresa`). En Android define el `applicationId` y en iOS/macOS el `Bundle Identifier`. Por defecto: `com.example`. |
| **`--project-name`** | `--project-name <nombre>` | Nombre del paquete Dart. Debe ser válido en Dart (solo minúsculas y guiones bajos `snake_case`). |
| **`--platforms`** | `--platforms=<lista>` | Lista de plataformas soportadas separadas por comas: `android`, `ios`, `macos`, `windows`, `linux`, `web`. |
| **`-a`, `--android-language`** | `-a <kotlin \| java>` | Lenguaje para el código nativo de Android. Por defecto: `kotlin`. |
| **`-i`, `--ios-language`** | `-i <swift \| objc>` | Lenguaje para el código nativo de iOS. Por defecto: `swift`. |
| **`-t`, `--template`** | `-t <app \| module \| package \| plugin>` | Tipo de proyecto a crear. Por defecto: `app`. |
| **`--description`** | `--description "<texto>"` | Descripción guardada en el `pubspec.yaml`. |
| **`--empty`** | `--empty` | Crea un proyecto básico mínimo sin comentarios ni el código de demostración del contador. |

---

### Creación Exclusiva para Android

Crea una aplicación configurada únicamente con la carpeta y dependencias nativas de **Android**.

* **Estructura:**
  ```bash
  flutter create --platforms=android --org <dominio_invertido> -a <kotlin|java> <nombre_proyecto>
  ```
* **Ejemplo práctico:**
  ```bash
  flutter create \
    --platforms=android \
    --org com.miempresa \
    --project-name mi_app_android \
    -a kotlin \
    --description "Aplicación móvil optimizada para Android" \
    mi_app_android
  ```

---

### Creación Exclusiva para iOS

Crea una aplicación configurada únicamente con la carpeta y dependencias nativas de **iOS**.

* **Estructura:**
  ```bash
  flutter create --platforms=ios --org <dominio_invertido> -i <swift|objc> <nombre_proyecto>
  ```
* **Ejemplo práctico:**
  ```bash
  flutter create \
    --platforms=ios \
    --org com.miempresa \
    --project-name mi_app_ios \
    -i swift \
    --description "Aplicación móvil optimizada para iOS" \
    mi_app_ios
  ```

---

### Creación Exclusiva para macOS

Crea una aplicación de escritorio configurada únicamente para **macOS**.

> [!NOTE]
> Requiere tener macOS Desktop habilitado en Flutter (`flutter config --enable-macos-desktop`) y Xcode instalado.

* **Estructura:**
  ```bash
  flutter create --platforms=macos --org <dominio_invertido> <nombre_proyecto>
  ```
* **Ejemplo práctico:**
  ```bash
  flutter create \
    --platforms=macos \
    --org com.miempresa \
    --project-name mi_app_macos \
    --description "Aplicación de escritorio para macOS" \
    mi_app_macos
  ```

---

### Creación Exclusiva para Windows

Crea una aplicación de escritorio configurada únicamente para **Windows**.

> [!NOTE]
> Para compilar y ejecutar en Windows se requiere Windows Desktop habilitado (`flutter config --enable-windows-desktop`) y herramientas de Visual Studio C++ instaladas.

* **Estructura:**
  ```bash
  flutter create --platforms=windows --org <dominio_invertido> <nombre_proyecto>
  ```
* **Ejemplo práctico:**
  ```bash
  flutter create \
    --platforms=windows \
    --org com.miempresa \
    --project-name mi_app_windows \
    --description "Aplicación de escritorio para Windows" \
    mi_app_windows
  ```

---

### Creación Multiplataforma Combinada

Si deseas crear una aplicación que soporte simultáneamente **Android, iOS, macOS y Windows** con su código base compartido en Dart:

* **Estructura:**
  ```bash
  flutter create --platforms=android,ios,macos,windows --org <dominio_invertido> <nombre_proyecto>
  ```
* **Ejemplo práctico completo:**
  ```bash
  flutter create \
    --platforms=android,ios,macos,windows \
    --org com.miempresa \
    --project-name calculadora_multiplataforma \
    -a kotlin \
    -i swift \
    --description "Calculadora científica multiplataforma para móvil y escritorio" \
    calculadora_multiplataforma
  ```

---

### Habilitar o Agregar Plataformas a un Proyecto Existente

Si ya tienes un proyecto creado y necesitas añadir soporte para una o más plataformas que no estaban habilitadas inicialmente:

1. **Asegurar que la plataforma de escritorio esté habilitada en Flutter:**
   ```bash
   flutter config --enable-macos-desktop
   flutter config --enable-windows-desktop
   ```
2. **Ejecutar `flutter create` dentro de la carpeta raíz del proyecto existente indicando las plataformas deseadas:**
   ```bash
   flutter create --platforms=android,ios,macos,windows .
   ```
   *(El punto `.` al final indica el directorio actual, inyectando las carpetas `android/`, `ios/`, `macos/` o `windows/` faltantes sin sobrescribir tu lógica en `lib/`).*
