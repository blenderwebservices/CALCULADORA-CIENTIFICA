# Plan de Implementación: Instalación de Flutter SDK en macOS

Este plan describe los pasos para instalar, configurar y validar Flutter SDK en el sistema macOS (Intel x86_64).

## 1. Diagnóstico del Entorno
- **Sistema Operativo:** macOS 14.8.9 (Sonoma)
- **Arquitectura:** Intel Core i5 (x86_64)
- **Shell por defecto:** `/bin/zsh`
- **Herramientas base disponibles:** `git`, `curl`, `tar`, `unzip`, Xcode Command Line Tools.

## 2. Estrategia de Instalación
- **Ubicación de instalación:** `~/development/flutter` (Ruta estándar recomendada por el equipo de Flutter).
- **Canal:** `stable` (Versión oficial estable para arquitectura x64).
- **Configuración de Variables de Entorno (`PATH`):**
  - Añadir `export PATH="$PATH:$HOME/development/flutter/bin"` en `~/.zshrc` y `~/.zprofile`.
  - Exportar para la sesión actual.

## 3. Inicialización y Diagnóstico (`flutter doctor`)
- Ejecutar `flutter doctor` para descargar las herramientas iniciales (Dart SDK y artefactos del motor).
- Evaluar el reporte de componentes:
  - Flutter SDK & Dart SDK.
  - Herramientas de macOS / Xcode.
  - Chrome / Web support.
  - Conexión con dispositivos (`flutter devices`).

## 4. Validación con el Proyecto
- Navegar a `/Users/franc/Herd/CALCULADORA-CIENTIFICA`.
- Ejecutar `flutter pub get` para validar la resolución de dependencias del proyecto.
- Ejecutar `flutter analyze` para verificar la integridad del código fuente.

## 5. Documentación y Entrega
- Guardar el reporte final en `docs/2026-10-16_HH-mm_walkthrough.md`.
