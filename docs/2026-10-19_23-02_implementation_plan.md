# Plan de Implementación: Diagnóstico y Resolución de Bloqueo en Flutter Doctor

**Fecha y Hora:** 2026-10-19 23:02 (Hora Local)  
**Proyecto:** Calculadora Científica & Suite Avanzada (`scientific_matrix_calculator`)  
**Normativa:** Cumplimiento con [AGENTS.md](file:///Users/franciscogomezbarragan/Herd/CALCULADORA-CIENTIFICA/AGENTS.md)

---

## 1. Objetivo

Identificar la causa raíz del bloqueo y crash por tiempo de espera (`exceeded maximum allowed duration of 0:04:30.000000`) en `flutter doctor` tanto en el validador de **Android toolchain** como en el de **Xcode**, y establecer los pasos de resolución y verificación para restablecer el funcionamiento normal de Flutter en el sistema macOS.

---

## 2. Diagnóstico Técnico de Causa Raíz

A través del análisis detallado de trazas de procesos (`ps`, `sample`, `launchctl`, `/usr/bin/log`, y código fuente de `flutter_tools`), se identificó la cadena exacta que bloquea el sistema:

1. **Bloqueo a Nivel de Sistema Operativo (`diskarbitrationd` / `fsck_exfat`):**
   - Se encuentra conectado un dispositivo de almacenamiento USB externo ("MING" / JMicron, partición exFAT `/dev/rdisk2s2`).
   - El sistema macOS (Sequoia 15.8.1) lanzó de forma automática el proceso de comprobación:  
     `/System/Library/Filesystems/exfat.fs/Contents/Resources/./fsck_exfat -y /dev/rdisk2s2` (PID `459`).
   - Dicho proceso ha permanecido en estado `U` (uninterruptible disk I/O) durante más de 45 minutos.
   - En macOS, mientras `fsck_exfat` mantiene bloqueado un disco, el demonio central de gestión de discos (`diskarbitrationd`) congela o bloquea todas las solicitudes de montaje e imágenes de disco (`DiskImages2`).

2. **Cascada de Bloqueo hacia CoreSimulator y Xcode:**
   - El servicio del sistema `simdiskimaged` (PID `849`) intentó montar imágenes del simulador y quedó en espera síncrona infinita de `diskarbitrationd` / `com.apple.diskimagescontroller`.
   - `com.apple.CoreSimulator.CoreSimulatorService` quedó congelado en su inicialización esperando respuesta Mach/XPC de `simdiskimaged`.
   - Como resultado, cualquier llamada a herramientas de Xcode como `xcrun simctl` (`simctl help`, `simctl list runtimes`, `simctl list devices booted`) queda completamente congelada.

3. **Cascada de Bloqueo hacia Flutter Doctor:**
   - Al ejecutar `flutter doctor`, Flutter arranca simultáneamente todos los validadores con un temporizador límite de 4 minutos y 30 segundos (`0:04:30.000000`).
   - El validador de **Xcode** invoca `simctl list runtimes` y se cuelga indefinidamente.
   - La detección de dispositivos conectados (`Connected Devices`) y el validador de **Android** también consultan el estado de simuladores (`simctl list devices booted`) o la enumeración USB de `adb`.
   - Al cumplirse 4:30 minutos, el temporizador expira y Flutter reporta:
     `Exception: Android toolchain - develop for Android devices exceeded maximum allowed duration of 0:04:30.000000`  
     `Exception: Xcode - develop for iOS and macOS exceeded maximum allowed duration of 0:04:30.000000`

---

## 3. Estado del Entorno de Desarrollo (Verificado y Correcto)

- **Flutter SDK:** Instalado y operativo en `/Users/franciscogomezbarragan/development/flutter` (Flutter 3.47.7, Dart 3.13.5).
- **Java JDK:** Instalado y configurado en `/Users/franciscogomezbarragan/development/jdk-17/Contents/Home` (OpenJDK Temurin 17.0.20.1).
- **Android SDK:** Instalado en `/Users/franciscogomezbarragan/Library/Android/sdk`.
- **Licencias de Android:** Verificadas y aceptadas (`All SDK package licenses accepted`).
- **Configuración de Flutter:** `android-sdk` y `jdk-dir` están correctamente enlazados en `~/.config/flutter/settings`.
- **Configuración Shell (`~/.zshrc`):** Rutas de `JAVA_HOME`, `ANDROID_HOME` y `PATH` configuradas adecuadamente.

---

## 4. Pasos de Remediación

1. **Liberar el Bloqueo del Sistema Operativo:**
   - **Opción A (Recomendada y rápida):** Desconectar de forma segura físicamente el dispositivo USB externo ("MING") o desconectar el hub USB. Esto hace que el kernel cancele de inmediato `fsck_exfat` y libere `diskarbitrationd`.
   - **Opción B (Vía terminal con permisos de administrador):** Finalizar el proceso colgado ejecutando:
     ```bash
     sudo pkill -9 fsck_exfat
     ```
2. **Reiniciar los Servicios del Simulador:**
   - Terminar cualquier proceso remanente congelado:
     ```bash
     killall -9 simctl 2>/dev/null
     killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null
     ```
3. **Verificación y Prueba Final:**
   - Comprobar que `xcrun simctl help` responde de inmediato.
   - Ejecutar `flutter doctor -v` para confirmar que todos los validadores pasan sin errores ni timeouts.
