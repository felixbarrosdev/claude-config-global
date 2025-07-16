# Sistema de Auto-Detección de Proyectos

## 🎯 Descripción General

El sistema de auto-detección de Claude Config Global analiza automáticamente tu proyecto para generar un `project-context.md` rico en información, mejorando significativamente la capacidad de Claude para entender y trabajar con tu proyecto específico.

## 🚀 Funcionalidades Implementadas

### 1. Detección Automática de Tecnologías
- **15+ tipos de proyecto** detectados automáticamente
- **Análisis de confianza** para cada detección
- **Extracción de metadatos** específicos por tecnología
- **Información de estructura** de archivos y directorios

### 2. Template Mejorado de project-context.md
- **Auto-población** de información detectada
- **Placeholders inteligentes** para tecnologías específicas
- **Resumen JSON** de la detección incluido
- **Fecha de generación** automática

### 3. Slash Command /load-project-context
- **Carga automática** del contexto en Claude
- **Resumen inteligente** de las tecnologías detectadas
- **Preparación** para asistencia contextualizada

## 🔧 Componentes del Sistema

### Scripts Principales
- `tools/detect-project.sh` - Motor de detección
- `tools/setup-project.sh` - Setup con auto-detección
- `tools/upgrade-to-full.sh` - Upgrade con auto-detección

### Templates y Prompts
- `templates/project-context.md` - Template mejorado
- `prompts/load-project-context.md` - Prompt original
- `slash-commands/load-project-context.md` - Slash command

### Archivos de Salida
- `.claude/project-context.md` - Contexto auto-generado
- `.claude/project-detection.json` - Datos brutos de detección

## 📋 Cómo Usar el Sistema

### Configuración Inicial

1. **Ejecutar Setup** (auto-detección incluida):
```bash
./.claude/tools/setup-project.sh
```

2. **Upgrade desde Lite** (auto-detección incluida):
```bash
./.claude/tools/upgrade-to-full.sh
```

3. **Solo Detección** (sin modificar archivos):
```bash
./.claude/tools/detect-project.sh
```

### Uso con Claude

1. **Cargar contexto automáticamente**:
```
/load-project-context
```

2. **Verificar información detectada**:
```bash
cat .claude/project-detection.json | jq .
```

3. **Revisar contexto generado**:
```bash
cat .claude/project-context.md
```

## 🔍 Información Auto-Detectada

### Tecnologías Soportadas
- **Node.js** - package.json, npm/yarn/pnpm
- **Python** - requirements.txt, poetry, conda
- **Rust** - Cargo.toml, cargo
- **Go** - go.mod, go modules
- **Java** - Maven, Gradle
- **PHP** - Composer
- **Ruby** - Bundler
- **Dart/Flutter** - pubspec.yaml
- **C#/.NET** - .csproj, .sln
- **C/C++** - CMake, Make
- **Web Frontend** - React, Vue, Angular, etc.
- **Mobile** - iOS, Android, React Native
- **Docker** - Dockerfile, docker-compose
- **Kubernetes** - manifests, Helm
- **Databases** - PostgreSQL, MySQL, MongoDB, Redis

### Metadatos Extraídos
- **Nombre del proyecto** y ubicación
- **Número total de archivos** y directorios
- **Extensiones de archivos** más comunes
- **Información de Git** (rama, commits, etc.)
- **Dependencias principales** y herramientas de build
- **Frameworks y librerías** utilizados

## 📊 Beneficios para Claude

### Antes (sin auto-detección)
```
Claude: "¿Qué tipo de proyecto tienes?"
Usuario: "Es un proyecto Node.js con React y PostgreSQL..."
Claude: "Entiendo, ahora puedo ayudarte mejor."
```

### Después (con auto-detección)
```
Usuario: "/load-project-context"
Claude: "✅ Contexto cargado! 
📊 Proyecto: felixbarros (Node.js)
🛠️ Stack: nodejs, web-frontend, docker
🏗️ Arquitectura: 847 archivos, npm/yarn
📋 Listo para asistencia contextualizada!"
```

## ⚡ Ventajas del Sistema

### Para el Desarrollador
- **Setup más rápido** - información auto-detectada
- **Menos explicaciones** - Claude entiende el contexto
- **Consistencia** - respuestas alineadas al stack tecnológico
- **Actualización automática** - re-detección fácil

### Para Claude
- **Contexto inmediato** del proyecto
- **Decisiones informadas** basadas en tecnologías detectadas
- **Sugerencias idiomáticas** según el stack
- **Mejor comprensión** de la arquitectura

## 🛠️ Configuración Avanzada

### Variables de Entorno Detectadas
El sistema exporta automáticamente:
- `DETECTED_TECHNOLOGIES` - Lista de tecnologías detectadas
- `PRIMARY_FRAMEWORK` - Framework principal
- `FILE_COUNT` - Número total de archivos
- `BUILD_TOOL` - Herramienta de construcción
- `PACKAGE_MANAGER` - Gestor de paquetes
- `FRAMEWORKS` - Frameworks web/móviles
- `DETECTED_DATABASES` - Bases de datos encontradas
- `CONTAINER_TECH` - Tecnologías de contenedores

### Personalización del Template
Puedes modificar `templates/project-context.md` para:
- Agregar secciones específicas de tu equipo
- Incluir placeholders adicionales
- Personalizar el formato de salida

## 🔄 Flujo de Trabajo Recomendado

1. **Inicio de sesión con Claude**:
   ```
   /load-project-context
   ```

2. **Trabajo normal** con Claude contextualizado

3. **Re-detección** cuando cambies tecnologías:
   ```bash
   ./.claude/tools/detect-project.sh
   ```

4. **Actualización** del contexto si es necesario:
   ```bash
   # Solo regenerar project-context.md
   cp .claude/templates/project-context.md .claude/
   # Ejecutar reemplazos...
   ```

## 🎯 Casos de Uso Principales

### 1. Nuevo Proyecto
- Clona claude-config-global
- Ejecuta setup-project.sh
- Obtén contexto automático rico

### 2. Proyecto Existente
- Ejecuta detect-project.sh
- Revisa la información detectada
- Usa /load-project-context con Claude

### 3. Migración Tecnológica
- Re-ejecuta detección después de cambios
- Actualiza project-context.md
- Recarga contexto en Claude

## 🔧 Troubleshooting

### Detección Incorrecta
```bash
# Ver resultados detallados
./.claude/tools/detect-project.sh --json | jq .

# Verificar niveles de confianza
jq '.detections[] | {type: .type, confidence: .confidence}' .claude/project-detection.json
```

### Missing jq
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

### Template No Actualizado
```bash
# Verificar placeholders reemplazados
grep -n "\[\[.*\]\]" .claude/project-context.md
```

## 📈 Roadmap Futuro

- **Detección de testing frameworks**
- **Análisis de código estático**
- **Integración con IDEs**
- **Templates específicos por tecnología**
- **Auto-actualización periódica**

---

**Desarrollado por**: Claude Config Global Team  
**Versión**: 2.0  
**Última actualización**: $(date)