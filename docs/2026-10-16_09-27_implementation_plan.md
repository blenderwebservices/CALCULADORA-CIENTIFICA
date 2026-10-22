# Plan de Implementación: Generación del Android App Bundle (.aab)

**Fecha y Hora:** 2026-10-16 09:27 (Hora Local)  
**Proyecto:** Calculadora Científica & Suite Avanzada (`scientific_matrix_calculator`)  
**Normativa:** Cumplimiento con [AGENTS.md](file:///Users/franciscogomezbarragan/Herd/CALCULADORA-CIENTIFICA/AGENTS.md)

---

## 1. Objetivo

Generar exitosamente el paquete de distribución para Google Play Store en formato **Android App Bundle (`.aab`)** optimizado para release, firmado con la clave de carga del proyecto (`upload-keystore.jks`), validando previamente el entorno de herramientas (Flutter 3.47.7, Dart 3.13.5, JDK 17) y la suite de pruebas unitarias y de widgets.

---

## 2. Diagnóstico del Entorno y Configuración

1. **Flutter SDK**:
   - Ubicación: `/Users/franciscogomezbarragan/development/flutter/bin/flutter`
   - Versión: `Flutter 3.47.7` / `Dart 3.13.5` (Canal stable)
2. **Java JDK**:
   - Ubicación: `/Users/franciscogomezbarragan/development/jdk-17/Contents/Home`
   - Versión: `OpenJDK 17.0.20.1 Temurin` (compatible con Gradle y Android Gradle Plugin)
3. **Firma de Release**:
   - Archivo de propiedades: `android/key.properties`
   - Almacén de claves: `android/app/upload-keystore.jks` (Alias: `upload`)
   - Configurado en `android/app/build.gradle.kts` bajo `signingConfigs.release`
4. **Versión de la Aplicación**:
   - `pubspec.yaml`: `version: 1.0.3+3` (Version Name: 1.0.3, Version Code: 3)
5. **Estado de Pruebas**:
   - `flutter test` ejecutado con éxito: 34 tests pasados (100% de éxito).

---

## 3. Pasos de Ejecución

1. Configurar variables de entorno `JAVA_HOME` y `PATH` en la sesión de ejecución.
2. Compilar el paquete Android App Bundle mediante:
   ```bash
   flutter build appbundle --release
   ```
3. Verificar la creación del artefacto en `build/app/outputs/bundle/release/app-release.aab`.
4. Obtener los metadatos del archivo generado (tamaño, ruta absoluta, fecha/hora).
5. Documentar el reporte de entrega en `docs/2026-10-16_09-XX_walkthrough.md` según las reglas del proyecto.
