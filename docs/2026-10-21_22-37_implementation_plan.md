# Plan de Implementación: Corrección de Flutter Run y Upgrade de JDK Java

**Fecha y Hora:** 2026-10-21 22:37 (Hora Local)  
**Proyecto:** Calculadora Científica & Suite Avanzada (`scientific_matrix_calculator`)  
**Normativa:** Cumplimiento con [AGENTS.md](file:///Users/franciscogomezbarragan/Herd/CALCULADORA-CIENTIFICA/AGENTS.md)

---

## 1. Contexto y Objetivos

El usuario solicitó:
1. "revisa el jdk java instalado y hazle upgrade al mas reciente (superior al 17)"
2. "no esta funcionando flutter run, revisa y corrige"

### Objetivos Principales:
1. **Desbloquear `flutter run`:**
   - Detectar la causa del congelamiento de `flutter run` y liberar el bloqueo de inicio (`startup lockfile`).
   - Identificar por qué el escaneo de dispositivos se bloqueaba en `simctl` / `CoreSimulatorService`.
   - Garantizar que la aplicación pueda compilarse y ejecutarse de inmediato en las plataformas locales (macOS desktop, Chrome web, o Android).
2. **Upgrade de Java JDK a la versión más reciente compatible (> 17):**
   - Evaluar versión instalada (`Temurin-17.0.20.1+1`).
   - Descargar e instalar Eclipse Temurin OpenJDK 21 LTS (la versión LTS superior a 17 estándar en la industria para Android/Gradle 8.14).
   - Configurar variables de entorno (`JAVA_HOME` en `~/.zshrc`) y directorio de JDK en Flutter (`flutter config --jdk-dir`).
   - Validar compatibilidad completa.

---

## 2. Diagnóstico Técnico

### A. Fallo de `flutter run`
- Un proceso previo de `flutter run` (PID 3873) quedó congelado en la terminal al intentar consultar los simuladores de iOS mediante `simctl list devices booted` (PID 3913).
- Causa raíz: Proceso `/System/Library/Filesystems/exfat.fs/Contents/Resources/./fsck_exfat -y /dev/rdisk2s2` (PID 465) bloqueado en estado ininterrumpible (`U`) sobre una unidad USB externa. Este proceso congela `diskarbitrationd`, el cual a su vez congela `simdiskimaged` y `CoreSimulatorService`.
- Cualquier llamada a `simctl` queda congelada indefinidamente.
- Flutter mantenía bloqueado su archivo de candado (`/Users/franciscogomezbarragan/development/flutter/bin/cache/lockfile`), haciendo que cualquier nuevo `flutter run` mostrara "Waiting for another flutter command to release the startup lock...".

### B. Estado del JDK
- Actualmente instalado: Eclipse Temurin OpenJDK 17.0.20.1 en `/Users/franciscogomezbarragan/development/jdk-17`.
- Arquitectura: macOS `x86_64`.
- Requerimiento: Upgrade a la versión más reciente superior a 17.
- Selección técnica: Eclipse Temurin OpenJDK 21 LTS (versión `21.0.12.1+1`).
  - *Justificación:* Es la versión LTS más moderna plenamente certificada para Gradle 8.14 y Android Gradle Plugin 8.x, garantizando estabilidad sin romper compilaciones móviles.

---

## 3. Fases de Ejecución

### Fase 1: Liberación y Prueba de Flutter Run
- [x] Terminar procesos bloqueados (`flutter run` y `simctl`).
- [x] Confirmar liberación del candado de Flutter (`flutter --version` respondiendo en < 1s).
- [x] Configurar temporalmente `flutter config --no-enable-ios` para evitar que el escaneo general de dispositivos invoque `simctl` mientras el disco USB siga conectado.
- [x] Validar que `flutter analyze` pasa sin advertencias ni errores (0 issues).
- [x] Ejecutar la suite de pruebas unitarias (`flutter test`: 34 pruebas exitosas).
- [/] Validar compilación de `flutter build macos --debug` o ejecución en Chrome/macOS.

### Fase 2: Descarga e Instalación de OpenJDK 21 LTS
- [ ] Descargar el paquete binario oficial de Eclipse Adoptium: `OpenJDK21U-jdk_x64_mac_hotspot_21.0.12.1_1.tar.gz`.
- [ ] Extraer en `/Users/franciscogomezbarragan/development/jdk-21`.
- [ ] Actualizar `~/.zshrc`:
  ```bash
  export JAVA_HOME="/Users/franciscogomezbarragan/development/jdk-21/Contents/Home"
  ```
- [ ] Configurar Flutter para usar el nuevo JDK:
  ```bash
  flutter config --jdk-dir "/Users/franciscogomezbarragan/development/jdk-21/Contents/Home"
  ```
- [ ] Verificar `java -version` y `/usr/libexec/java_home -V`.

### Fase 3: Verificación Integral y Documentación
- [ ] Probar compilación/análisis con el nuevo JDK 21.
- [ ] Documentar instrucciones para el usuario sobre el disco USB y cómo desbloquear el simulador de iOS si lo requiere.
- [ ] Elaborar el reporte de entrega final `docs/2026-10-21_22-37_walkthrough.md`.
